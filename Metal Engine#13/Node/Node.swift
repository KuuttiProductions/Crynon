
import MetalKit

//Node is anything that can be placed in a scene,
//even the scene itself.
//Can be 2D or 3D, be rendered or not, really
//it's just a superclass for objects in the scene.
class Node {
    
    var name: String!
    var uuid: String!
    
    private var _children: [Node] = []
    
    private var _position: simd_float3 = simd_float3(0, 0, 0)
    private var _rotation: simd_float3 = simd_float3(0, 0, 0)
    private var _scale: simd_float3 = simd_float3(1, 1, 1)
    
    public var position: simd_float3 { return _position }
    public var rotation: simd_float3 { return _rotation }
    public var scale: simd_float3 { return _scale }
    
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
    func tick() {
        for node in _children {
            node.tick()
        }
    }
    
    //Called 60 times per second. For Physics based logic
    func physicsTick() {
        for node in _children {
            node.physicsTick()
        }
    }
    
    //Called every frame.
    func render() {
        for node in _children {
            node.render()
        }
    }
}
