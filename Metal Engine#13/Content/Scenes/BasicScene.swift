
import MetalKit

class BasicScene: Scene {
    
    let triangle = Triangle()
    let camera = Camera("FPSCamera")
    
    var time: Float = 0.0
    
    init() {
        super.init("BasicScene")
        addChild(triangle)
        addCamera(camera, true)
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        camera.setPosY(sin(time))
        print(camera.position.y)
        time += deltaTime
    }
}
