
import MetalKit

//Node is anything that can be placed in a scene,
//even the scene itself.
//Can be 2D, 3D, rendered or not, really
//it's just a superclass for objects in the scene.
open class Node {
    
    public var name: String!
    public var uuid: String!
    
    private var parent: Node!
    
    public var _children: [Node] = []
    
    private var _position: simd_float3 = simd_float3(0, 0, 0)
    private var _rotation: simd_float3 = simd_float3(0, 0, 0)
    private var _scale: simd_float3 = simd_float3(1, 1, 1)
    
    public var position: simd_float3 { return _position }
    public var rotation: simd_float3 { return _rotation }
    public var scale: simd_float3 { return _scale }
    
    internal var modelConstant = ModelConstant()
    
    internal var modelMatrix: matrix_float4x4 {
        var modelMatrix = matrix_identity_float4x4
        modelMatrix.translate(position: position)
        modelMatrix.rotate(direction: rotation.x, axis: .AxisX)
        modelMatrix.rotate(direction: rotation.y, axis: .AxisY)
        modelMatrix.rotate(direction: rotation.z, axis: .AxisZ)
        modelMatrix.scale(scale)
        return modelMatrix
    }
    
    public init(_ name: String) {
        self.name = name
        self.uuid = UUID().uuidString
    }
    
    public func addChild(_ child: Node) {
        child.parent = self
        _children.append(child)
    }
    
    public func removeChild(_ index: Int) {
        _children.remove(at: index)
    }
    
    public func removeChild(_ uuid: String) {
        for child in _children {
            var i = 0
            if child.uuid == uuid {
                _children.remove(at: i)
                break
            } else {
                i += 1
            }
        }
    }
    
    public func getScene()-> Scene {
        return parent.getScene()
    }
    
    //Called every frame. For logic that doesn't need physical accuracy
    internal func tick(_ deltaTime: Float) {
        if parent != nil {
            self.modelConstant.modelMatrix = matrix_multiply(self.parent.modelMatrix, self.modelMatrix)
        } else {
            self.modelConstant.modelMatrix = self.modelMatrix
        }
        tickCustom(deltaTime)
        for node in _children {
            node.tick(deltaTime)
        }
    }
    
    //Called 60 times per second. For Physics based logic
    internal func physicsTick(_ deltaTime: Float) {
        for node in _children {
            node.physicsTick(deltaTime)
        }
    }
    
    //Called every frame.
    internal func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        for node in _children {
            node.render(renderCommandEncoder)
        }
        renderCustom(renderCommandEncoder)
        renderCommandEncoder.popDebugGroup()
    }
    
    //Every frame. For rendering to shadowMaps
    internal func castShadow(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        for node in _children {
            node.castShadow(renderCommandEncoder)
        }
        renderCommandEncoder.popDebugGroup()
    }
    
    open func renderCustom(_ renderCommandEncoder: MTLRenderCommandEncoder!) {}
    open func tickCustom(_ deltaTime: Float) {}
}

extension Node {
    public var forwardVector: simd_float3 { return normalize(simd_float3(
        sin(rotation.y) * cos(rotation.x),
        -sin(rotation.x),
        -cos(rotation.y) * cos(rotation.x))) }
    public var rightVector: simd_float3 { return  normalize(simd_float3(sin(rotation.y + Float.pi*0.5), 0, -cos(rotation.y + Float.pi*0.5))) }
}

//Pos, Rot, Scale functions
extension Node {
    //Position
    public func setPosX(_ value: Float) {
        self._position.x = value
    }
    public func setPosY(_ value: Float) {
        self._position.y = value
    }
    public func setPosZ(_ value: Float) {
        self._position.z = value
    }
    
    public func setPos(_ value: simd_float3) {
        self._position = value
    }
    public func setPos(_ x: Float, _ y: Float, _ z: Float) {
        self._position = simd_float3(x, y, z)
    }
    
    public func addPosX(_ value: Float) {
        self._position.x += value
    }
    public func addPosY(_ value: Float) {
        self._position.y += value
    }
    public func addPosZ(_ value: Float) {
        self._position.z += value
    }
    public func addPos(_ value: simd_float3) {
        self._position += value
    }
    
    //Rotation
    public func setRotX(_ value: Float) {
        self._rotation.x = value
    }
    public func setRotY(_ value: Float) {
        self._rotation.y = value
    }
    public func setRotZ(_ value: Float) {
        self._rotation.z = value
    }
    
    public func setRot(_ value: simd_float3) {
        self._rotation = value
    }
    public func setRot(_ x: Float, _ y: Float, _ z: Float) {
        self._rotation = simd_float3(x, y, z)
    }
    
    public func addRotX(_ value: Float) {
        self._rotation.x += value
    }
    public func addRotY(_ value: Float) {
        self._rotation.y += value
    }
    public func addRotZ(_ value: Float) {
        self._rotation.z += value
    }
    public func addRot(_ value: simd_float3) {
        self._rotation += value
    }
    
    //Scale
    public func setScaleX(_ value: Float) {
        self._scale.x = value
    }
    public func setScaleY(_ value: Float) {
        self._scale.y = value
    }
    public func setScaleZ(_ value: Float) {
        self._scale.z = value
    }
    
    public func setScale(_ value: Float) {
        self._scale = simd_float3(repeating: value)
    }
    
    public func setScale(_ value: simd_float3) {
        self._scale = value
    }
    public func setScale(_ x: Float, _ y: Float, _ z: Float) {
        self._scale = simd_float3(x, y, z)
    }
}
