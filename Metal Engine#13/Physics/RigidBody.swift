
import MetalKit

class RigidBody: Node {
    
    //Physics variables
    var orientation: simd_float3x3 = simd_float3x3()
    var invOrientation: simd_float3x3 = simd_float3x3()
    
    var localInvInertiaTensor: simd_float3x3 = simd_float3x3()
    var globalInvInertiaTensor: simd_float3x3 = simd_float3x3()
    
    var mass: Float = 1
    var invMass: Float = 1
    var localCenterOfMass: simd_float3 = simd_float3(0, 0, 0)
    var globalCenterOfMass: simd_float3 = simd_float3(0, 0, 0)
    
    var linearVelocity: simd_float3 = simd_float3(0, 0, 0)
    var angularVelocity: simd_float3 = simd_float3(0, 0, 0)
    
    var forceAccumulator: simd_float3 = simd_float3(0, 0, 0)
    var torqueAccumulator: simd_float3 = simd_float3(0, 0, 0)
    
    var colliders: [Collider] = []
    
    var mesh: MeshType = .Cube
    var aabbSimple: [simd_float3] = []
    var aabbMin: simd_float3 = simd_float3(repeating: 0)
    var aabbMax: simd_float3 = simd_float3(repeating: 0)
    
    var isActive: Bool = true
    var isColliding: Bool = false
    
    //Debug
    var debug_drawAABB: Bool = false
    var debug_drawCollisionState: Bool = false
    var debug_simplex: [simd_float3] = []
    var debug_x: Float = 0
    var debug_y: Float = 0
    
    //End of physics variables
    var material: Material = Material()
    
    private var aabbPoints: [PointVertex] = [PointVertex(),
                                             PointVertex(),
                                             PointVertex(),
                                             PointVertex(),
                                             PointVertex(),
                                             PointVertex(),
                                             PointVertex(),
                                             PointVertex()]
    
    override init(_ name: String) {
        super.init(name)
        
        self.orientation.columns = (
            simd_float3(1, 0, 0),
            simd_float3(0, 1, 0),
            simd_float3(0, 0, 1)
        )
        self.invOrientation = self.orientation.inverse
        
        self.globalInvInertiaTensor.columns = (
            simd_float3(1, 0, 0),
            simd_float3(0, 1, 0),
            simd_float3(0, 0, 1)
        )
        self.addCollider(Collider(true))
        
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
    
    func localToGlobal(point: simd_float3)-> simd_float3 {
        return invOrientation * point + position
    }
    func globalToLocal(point: simd_float3)-> simd_float3 {
        return orientation * (point - position)
    }
    func localToGlobalDir(dir: simd_float3)-> simd_float3 {
        return invOrientation * dir
    }
    func globalToLocalDir(dir: simd_float3)-> simd_float3 {
        return orientation * dir
    }
    
    func updateGlobalCenterOfMassFromPosition() {
        globalCenterOfMass = orientation * localCenterOfMass + position
    }
    func updatePositionFromGlobalCenterOfMass() {
        setPos(orientation * (-localCenterOfMass) + globalCenterOfMass)
    }
    func updateOrientation() {
        var quat: simd_quatf = simd_quatf(orientation)
        quat = quat.normalized
        orientation = matrix_float3x3(quat)
        
        invOrientation = orientation.inverse
    }
    func updateInvInertiaTensor() {
        globalInvInertiaTensor = orientation * localInvInertiaTensor * invOrientation
    }
    
    func addCollider(_ collider: Collider) {
        colliders.append(collider)
        collider.body = self
        
        localCenterOfMass = simd_float3()
        mass = 0
        
        for collider in colliders {
            mass += collider.mass
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
        
        localInvInertiaTensor = localInertiaTensor.inverse
    }
    
    func addForce(force: simd_float3, at: simd_float3) {
        forceAccumulator += force
        torqueAccumulator += cross((at - localCenterOfMass), force)
    }
    
    func addAngularForce(force: simd_float3) {
        torqueAccumulator += force
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)

        if name == "physics2" {
            if InputManager.mouseLeftButton {
                self.addForce(force: simd_float3(0, 20, 0), at: simd_float3(0, 0, 0))
            }
            if InputManager.pressedKeys.contains(.keyQ) {
                self.addForce(force: simd_float3(0, 0, 1), at: simd_float3(0.1, 0, 0))
            } else if InputManager.pressedKeys.contains(.keyE) {
                self.addForce(force: simd_float3(0, 0, -1), at: simd_float3(0.1, 0, 0))
            }
        }
        
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
        if material.blendMode == Renderer.currentBlendMode && material.visible {
            if isActive && debug_drawCollisionState {
                if isColliding {
                    self.material.shaderMaterial.color = simd_float4(1, 0, 0, 1)
                } else {
                    self.material.shaderMaterial.color = simd_float4(0, 1, 0, 1)
                }
            }

            renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[material.shader])
            renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[material.shader == .Transparent ? .NoWriteAlways : .Less])
            renderCommandEncoder.setFragmentBytes(&material.shaderMaterial, length: ShaderMaterial.stride, index: 1)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureColor], index: 3)
            renderCommandEncoder.setVertexBytes(&modelConstant, length: ModelConstant.stride, index: 1)
            AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder)
            
            if debug_drawAABB {
                Debug.pointAndLine.drawPoints(renderCommandEncoder: renderCommandEncoder, points: aabbPoints, color: simd_float4(1, 0.2, 0, 1))
                Debug.pointAndLine.drawLineStrip(renderCommandEncoder: renderCommandEncoder, points: aabbPoints, color: simd_float4(0, 1, 0, 1))
            }
            Debug.vector.drawVector(renderCommandEncoder: renderCommandEncoder,
                                    vector: simd_float3(cos(Renderer.time), sin(Renderer.time), 0),
                                    origin: simd_float3(0, 0, 0),
                                    color: simd_float4(1, 1, 1, 1),
                                    emissive: false)
            if isActive {
                for collider in colliders {
                    var points: [simd_float3] = []
                    for vertex in collider.vertices {
                        points.append(localToGlobal(point: vertex))
                    }
                    Debug.pointAndLine.drawLineStrip(renderCommandEncoder: renderCommandEncoder, positions: points, color: material.shaderMaterial.color)
                }
            }
            if !debug_simplex.isEmpty { Debug.pointAndLine.drawLineStrip(renderCommandEncoder: renderCommandEncoder, positions: debug_simplex, color: simd_float4(0, 0, 1, 1)) }
        }
        super.render(renderCommandEncoder)
    }
    
    override func castShadow(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.pushDebugGroup("Casting Shadow on \(name!)")
        renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[.Shadow])
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
        renderCommandEncoder.setFragmentBytes(&material.shaderMaterial, length: ShaderMaterial.stride, index: 1)
        renderCommandEncoder.setFragmentTexture(AssetLibrary.textures["Wallpaper"], index: 3)
        renderCommandEncoder.setVertexBytes(&modelConstant, length: ModelConstant.stride, index: 1)
        renderCommandEncoder.setCullMode(.back)
        AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder)
        
        super.castShadow(renderCommandEncoder)
    }
}

extension RigidBody {
    func setPos(_ x: Float, _ y: Float, _ z: Float, teleport: Bool) {
        if !teleport {
            linearVelocity = simd_float3(0, 0, 0)
            angularVelocity = simd_float3(0, 0, 0)
        }
        setPos(x, y, z)
        updateGlobalCenterOfMassFromPosition()
    }
}
