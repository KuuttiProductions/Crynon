
import MetalKit

//Node is anything that can be placed in a scene,
//even the scene itself.
//Can be 2D or 3D, be rendered or not, really
//it's just a superclass for objects in the scene.
class Node {
    
    var name: String!
    var uuid: String!
    
    internal var modelConstant = ModelConstant()
    
    private var _children: [Node] = []
    
    private var _position: simd_float3 = simd_float3(0, 0, 0)
    private var _rotation: simd_float3 = simd_float3(0, 0, 0)
    private var _scale: simd_float3 = simd_float3(1, 1, 1)
    
    public var position: simd_float3 { return _position }
    public var rotation: simd_float3 { return _rotation }
    public var scale: simd_float3 { return _scale }
    
    var modelMatrix: matrix_float4x4 {
        var modelMatrix = matrix_identity_float4x4
        modelMatrix.translate(position: position)
        modelMatrix.rotate(direction: rotation.x, axis: .AxisX)
        modelMatrix.rotate(direction: rotation.y, axis: .AxisY)
        modelMatrix.rotate(direction: rotation.z, axis: .AxisZ)
        modelMatrix.scale(scale)
        return modelMatrix
    }
    
    init(_ name: String) {
        self.name = name
        self.uuid = UUID().uuidString
    }
    
    func addChild(_ child: Node) {
        _children.append(child)
    }
    
    func removeChildAtIndex(_ index: Int) {
        _children.remove(at: index)
    }
    
    func removeChildOfUUID(_ uuid: String) {
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
    
    //Called every frame. For logic that doesn't need physical accuracy
    func tick(_ deltaTime: Float) {
        self.modelConstant.modelMatrix = self.modelMatrix
        for node in _children {
            node.tick(deltaTime)
        }
    }
    
    //Called 60 times per second. For Physics based logic
    func physicsTick() {
        for node in _children {
            node.physicsTick()
        }
    }
    
    //Called every frame.
    func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        for node in _children {
            node.render(renderCommandEncoder)
        }
    }
}

//Pos, Rot, Scale functions
extension Node {
    //Position
    func setPosX(_ value: Float) {
        self._position.x = value
    }
    func setPosY(_ value: Float) {
        self._position.y = value
    }
    func setPosZ(_ value: Float) {
        self._position.z = value
    }
    
    func setPos(_ value: simd_float3) {
        self._position = value
    }
    func setPos(_ x: Float, _ y: Float, _ z: Float) {
        self._position = simd_float3(x, y, z)
    }
    
    func addPosX(_ value: Float) {
        self._position.x += value
    }
    func addPosY(_ value: Float) {
        self._position.y += value
    }
    func addPosZ(_ value: Float) {
        self._position.z += value
    }
    
    //Rotation
    func setRotX(_ value: Float) {
        self._rotation.x = value
    }
    func setRotY(_ value: Float) {
        self._rotation.y = value
    }
    func setRotZ(_ value: Float) {
        self._rotation.z = value
    }
    
    func setRot(_ value: simd_float3) {
        self._rotation = value
    }
    func setRot(_ x: Float, _ y: Float, _ z: Float) {
        self._rotation = simd_float3(x, y, z)
    }
    
    func addRotX(_ value: Float) {
        self._rotation.x += value
    }
    func addRotY(_ value: Float) {
        self._rotation.y += value
    }
    func addRotZ(_ value: Float) {
        self._rotation.z += value
    }
    
    //Scale
    func setScaleX(_ value: Float) {
        self._scale.x = value
    }
    func setScaleY(_ value: Float) {
        self._scale.y = value
    }
    func setScaleZ(_ value: Float) {
        self._scale.z = value
    }
    
    func setScale(_ value: simd_float3) {
        self._scale = value
    }
    func setScale(_ x: Float, _ y: Float, _ z: Float) {
        self._scale = simd_float3(x, y, z)
    }
}
