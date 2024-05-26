
import MetalKit

open class RigidBody: Node {
    
    //Physics variables
    internal var orientation: simd_float3x3 = matrix_identity_float3x3 // Rotation
    internal var invOrientation: simd_float3x3 = matrix_identity_float3x3
    internal var rotationMatrix: simd_float4x4 = matrix_identity_float4x4
    
    internal var InvInertiaTensor: simd_float3x3 = matrix_identity_float3x3
    
    public var mass: Float { return _mass }
    internal var _mass: Float = 1.0
    internal var invMass: Float = 1.0
    internal var localCenterOfMass: simd_float3 = simd_float3(0, 0, 0)
    internal var globalCenterOfMass: simd_float3 = simd_float3(0, 0, 0)
    
    public var gravityScalar: Float = 1.0
    public var friction: Float = 0.5
    public var bounciness: Float = 0.0
    
    public var linearVelocity: simd_float3 = simd_float3(0, 0, 0)
    public var angularVelocity: simd_float3 = simd_float3(0, 0, 0)
    
    internal var forceAccumulator: simd_float3 = simd_float3(0, 0, 0)
    internal var torqueAccumulator: simd_float3 = simd_float3(0, 0, 0)
    
    internal var scaleMatrix: matrix_float3x3 = matrix_identity_float3x3
    
    var colliders: [Collider] = []
    
    var aabbSimple: [simd_float3] = []
    var aabbMin: simd_float3 = simd_float3(repeating: 0)
    var aabbMax: simd_float3 = simd_float3(repeating: 0)

    public var collides: Bool = true
    var isColliding: Bool = false
    internal var collidingBodies: [String] = []
    
    //Debug
    var debug_drawAABB: Bool = false
    var debug_drawCollisionState: Bool = false
    var debug_contactPoint: simd_float3!
    
    //End of physics variables
    public var materials: [Material] = []
    public var mesh: String = "Cube"
    
    private var aabbPoints: [PointVertex] = [PointVertex(),
                                             PointVertex(),
                                             PointVertex(),
                                             PointVertex(),
                                             PointVertex(),
                                             PointVertex(),
                                             PointVertex(),
                                             PointVertex()]
    
    public override init(_ name: String) {
        super.init(name)
        
        let verticePointer = AssetLibrary.meshes[mesh].vertexBuffer.contents()
        var positions: [simd_float3] = []
        
        for i in 0..<AssetLibrary.meshes[mesh].vertexBuffer.length/Vertex.stride {
            let item = verticePointer.load(fromByteOffset: Vertex.stride(count: i), as: Vertex.self).position
            positions.append(item)
        }
        
        var minX: Float = .infinity
        var minY: Float = .infinity
        var minZ: Float = .infinity
        var maxX: Float = -.infinity
        var maxY: Float = -.infinity
        var maxZ: Float = -.infinity
        
        for pos in positions {
            
            if pos.x < minX {
                minX = pos.x
            }
            if pos.x > maxX {
                maxX = pos.x
            }

            if pos.y < minY {
                minY = pos.y
            }
            if pos.y > maxY {
                maxY = pos.y
            }

            if pos.z < minZ {
                minZ = pos.z
            }
            if pos.z > maxZ {
                maxZ = pos.z
            }
        }
        
        aabbSimple = [
            simd_float3(minX, minY, minZ),
            simd_float3(minX, minY, maxZ),
            simd_float3(minX, maxY, minZ),
            simd_float3(minX, maxY, maxZ),
            simd_float3(maxX, maxY, maxZ),
            simd_float3(maxX, maxY, minZ),
            simd_float3(maxX, minY, maxZ),
            simd_float3(maxX, minY, minZ)
        ]
    }
    
    // Override modelMatrix to use RigidBodies rotationMatrix
    public override var modelMatrix: matrix_float4x4 {
        var modelMatrix = matrix_identity_float4x4
        modelMatrix.translate(position: position)
        modelMatrix = matrix_multiply(modelMatrix, rotationMatrix)
        modelMatrix.scale(scale)
        return modelMatrix
    }
    
    public func addCollider(_ mesh: String) {
        self.addCollider(Collider(mesh: mesh))
    }
    
    internal func localToGlobal(point: simd_float3)-> simd_float3 {
        return invOrientation * point + position
    }
    internal func globalToLocal(point: simd_float3)-> simd_float3 {
        return orientation * (point - position)
    }
    internal func localToGlobalDir(dir: simd_float3)-> simd_float3 {
        return invOrientation * dir
    }
    internal func globalToLocalDir(dir: simd_float3)-> simd_float3 {
        return orientation * dir
    }
    
    // Re-orthogonalize orientation and update rotationMatrix
    internal func updateOrientation() {
        let quaternion: simd_quatf = simd_quatf(orientation)
        let unitQuaternion = quaternion.normalized
        orientation = matrix_float3x3(unitQuaternion)
        rotationMatrix = matrix_float4x4(unitQuaternion)
        invOrientation = orientation.inverse
    }
    internal func updateGlobalCenterOfMassFromPosition() {
        globalCenterOfMass = orientation * localCenterOfMass + position
    }
    internal func updatePositionFromGlobalCenterOfMass() {
        setPos(orientation * (-localCenterOfMass) + globalCenterOfMass)
    }
    
    internal func addCollider(_ collider: Collider) {
        colliders.append(collider)
        collider.body = self
        
        localCenterOfMass = simd_float3()
        _mass = 0
        
        for collider in colliders {
            _mass += collider.mass
            localCenterOfMass += collider.mass * collider.localCenterOfMass
        }
        
        invMass = 1 / mass
        
        localCenterOfMass *= invMass
        
        var localInertiaTensor: simd_float3x3 = simd_float3x3(0)
        for collider in colliders {
            let r: simd_float3 = localCenterOfMass - collider.localCenterOfMass
            let rDotR: Float = dot(r, r)
            let rOutR: simd_float3x3 = matrix_float3x3.outerProduct(r, r)
            
            localInertiaTensor += collider.localInertiaTensor + collider.mass * (rDotR * matrix_identity_float3x3 - rOutR)
        }
        
        invOrientation = orientation.inverse
    }
    
    public  func addForce(force: simd_float3, at: simd_float3) {
        forceAccumulator += force
        torqueAccumulator += cross(at - localCenterOfMass, force)
    }
    
    public func addAngularForce(force: simd_float3) {
        torqueAccumulator += force
    }
    
    public func setMass(mass: Float) {
        self._mass = mass
        if mass < .greatestFiniteMagnitude {
            self.invMass = 1.0 / mass
        } else {
            self.invMass = 0.0
        }
    }
    
    open func onBeginCollide(collidingObject: RigidBody)-> Bool { return true }
    
    open func onEndCollide(collidingObject: RigidBody) {}
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)

        scaleMatrix = matrix_identity_float3x3
        scaleMatrix.scale(self.scale)
        
        var min: simd_float3 = simd_float3(repeating: .infinity)
        var max: simd_float3 = simd_float3(repeating: -.infinity)
        
        for pos in aabbSimple {
            let comparePos = matrix_multiply(self.modelMatrix, simd_float4(pos, 1))
            
            if comparePos.x < min.x {
                min.x = comparePos.x
            }
            if comparePos.x > max.x {
                max.x = comparePos.x
            }

            if comparePos.y < min.y {
                min.y = comparePos.y
            }
            if comparePos.y > max.y {
                max.y = comparePos.y
            }

            if comparePos.z < min.z {
                min.z = comparePos.z
            }
            if comparePos.z > max.z {
                max.z = comparePos.z
            }
        }
        
        aabbMin = min
        aabbMax = max
        
        for i in 0..<8 {
            switch i {
            case 0:
                aabbPoints[i].position = aabbMin
            case 1:
                aabbPoints[i].position = simd_float3(aabbMin.x, aabbMin.y, aabbMax.z)
            case 2:
                aabbPoints[i].position = simd_float3(aabbMin.x, aabbMax.y, aabbMin.z)
            case 3:
                aabbPoints[i].position = simd_float3(aabbMin.x, aabbMax.y, aabbMax.z)
            case 4:
                aabbPoints[i].position = aabbMax
            case 5:
                aabbPoints[i].position = simd_float3(aabbMax.x, aabbMax.y, aabbMin.z)
            case 6:
                aabbPoints[i].position = simd_float3(aabbMax.x, aabbMin.y, aabbMax.z)
            case 7:
                aabbPoints[i].position = simd_float3(aabbMax.x, aabbMin.y, aabbMin.z)
            default:
                continue
            }
            aabbPoints[i].pointSize = 50
        }
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.pushDebugGroup("Rendering \(name!)")
        renderCommandEncoder.setVertexBytes(&self.modelConstant, length: ModelConstant.stride, index: 1)
        AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder, materials: materials)
        
        // Debug drawing
        if debug_drawAABB {
            Debug.pointAndLine.drawPoints(renderCommandEncoder: renderCommandEncoder, points: aabbPoints, color: simd_float4(1, 0.2, 0, 1))
            Debug.pointAndLine.drawLineStrip(renderCommandEncoder: renderCommandEncoder, points: aabbPoints, color: simd_float4(0, 1, 0, 1))
        }
        
        if debug_contactPoint != nil {
            Debug.pointAndLine.drawLine(renderCommandEncoder: renderCommandEncoder,
                                        position1: simd_float3(0, 0, 0),
                                        position2: debug_contactPoint, color: simd_float4(1, 0, 1, 1))
        }
        super.render(renderCommandEncoder)
    }
    
    override func castShadow(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.pushDebugGroup("Casting Shadow on \(name!)")
        renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[.Shadow])
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
        renderCommandEncoder.setVertexBytes(&modelConstant, length: ModelConstant.stride, index: 1)
        renderCommandEncoder.setCullMode(.back)
        AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder, materials: materials, applyRPState: false)
        
        super.castShadow(renderCommandEncoder)
    }
}

extension RigidBody {
    public func setPos(_ x: Float, _ y: Float, _ z: Float, teleport: Bool) {
        if !teleport {
            linearVelocity = simd_float3(0, 0, 0)
            angularVelocity = simd_float3(0, 0, 0)
        }
        setPos(x, y, z)
        updateGlobalCenterOfMassFromPosition()
    }
    public func setPos(_ position: simd_float3, teleport: Bool) {
        if !teleport {
            linearVelocity = simd_float3(0, 0, 0)
            angularVelocity = simd_float3(0, 0, 0)
        }
        setPos(position)
        updateGlobalCenterOfMassFromPosition()
    }
    
    public func addPos(_ value: simd_float3, teleport: Bool) {
        if !teleport {
            linearVelocity = simd_float3(0, 0, 0)
            angularVelocity = simd_float3(0, 0, 0)
        }
        addPos(value)
        updateGlobalCenterOfMassFromPosition()
    }
}
