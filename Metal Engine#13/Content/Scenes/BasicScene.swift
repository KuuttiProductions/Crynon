
import simd

class BasicScene: Scene {
    
    let triangle = Triangle()
    let camera = Camera("FPSCamera")
    let light = Light("PointLight")
    
    var time: Float = 0.0
    
    init() {
        super.init("BasicScene")
        addChild(triangle)
        addCamera(camera, true)
        addLight(light)
        camera.setPosZ(5)
        light.setPos(0, 5, 3)
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        triangle.setRotY(time)
        time += deltaTime
    }
}
