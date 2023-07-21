
import simd

class BasicScene: Scene {
    
    let object = Object(mesh: .Object)
    let cube = Object(mesh: .Cube)
    let camera = FPSCamera()
    let light = DirectionalLight()
    
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
        light.setPos(0, 2, 3)
        light.lightData.color = simd_float4(1,1,1,1)
        light.setRotX(Float(30).deg2rad)
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        time += deltaTime
        light.setRotX(Float((sin(time/5)*5 + 30).deg2rad))
    }
}
