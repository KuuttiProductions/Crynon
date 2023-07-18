
import simd

class BasicScene: Scene {
    
    let object = Object(mesh: .Object)
    let cube = Object(mesh: .Cube)
    let camera = FPSCamera()
    let light = Light("PointLight")
    
    var time: Float = 0.0
    
    init() {
        super.init("BasicScene")
        addChild(object)
        addChild(cube)
        addCamera(camera, true)
        addLight(light)
        cube.setPos(0, -3, 0)
        cube.setScale(5, 0.2, 5)
        camera.setPosZ(5)
        light.setPos(3, 5, 0)
        light.lightData.color = simd_float4(1,1,1,1)
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        time += deltaTime
        light.setPosZ(sin(time) * 5)
    }
}
