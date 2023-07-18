
import simd

class BasicScene: Scene {
    
    let triangle = Triangle()
    let camera = FPSCamera()
    let light = Light("PointLight")
    
    var time: Float = 0.0
    
    init() {
        super.init("BasicScene")
        addChild(triangle)
        addCamera(camera, true)
        addLight(light)
        camera.setPosZ(5)
        light.setPos(0, 5, 3)
        light.lightData.color = simd_float4(1,1,1,1)
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        time += deltaTime
        light.setPosZ(sin(time) * 5)
    }
}
