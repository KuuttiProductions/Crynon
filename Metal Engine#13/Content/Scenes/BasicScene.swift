
import simd

class BasicScene: Scene {
    
    let triangle = Triangle()
    let camera = FPSCamera()
    
    var time: Float = 0.0
    
    init() {
        super.init("BasicScene")
        addChild(triangle)
        addCamera(camera, true)
        camera.setPosZ(5)
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
    }
}
