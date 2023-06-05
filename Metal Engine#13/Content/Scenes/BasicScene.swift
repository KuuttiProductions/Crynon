
import simd

class BasicScene: Scene {
    
    let triangle = Triangle()
    let camera = Camera("FPSCamera")
    
    var time: Float = 0.0
    
    init() {
        super.init("BasicScene")
        addChild(triangle)
        addCamera(camera, true)
        camera.setPosZ(3)
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        triangle.setRotY(sin(time))
        time += deltaTime
    }
}
