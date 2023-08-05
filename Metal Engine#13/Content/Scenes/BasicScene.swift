
import simd

class BasicScene: Scene {
    
    let object = MetameshObject()
    let cube = CubeObject()
    let cube2 = CubeObject()
    let cube3 = CubeObject()
    let camera = FPSCamera()
    let sun = DirectionalLight()
    let light = PointLight()
    let physics = RigidBody("Cube")
    
    var time: Float = 0.0
    
    init() {
        super.init("BasicScene")
        addChild(object)
        addChild(cube)
        addChild(cube2)
        addChild(cube3)
        addCamera(camera, true)
        addLight(sun)
        addLight(light)
        addPhysicsObject(physics)
        object.setPosX(-4)
        cube.setPos(0, -3, 0)
        cube.setScale(300, 0.2, 10)
        cube2.setPosX(20)
        cube3.setPos(4, -2, 0)
        cube3.setRotY(Float(30.deg2rad))
        camera.setPosZ(5)
        physics.setPosY(5)
        sun.lightData.color = simd_float4(1,1,1,1)
        sun.setRotX(Float(45).deg2rad)
        light.setPosY(1)
        sun.lightData.brightness = 0.2
        light.lightData.brightness = 1.0
        light.lightData.color = simd_float4(0, 1, 1, 1)
        
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        time += deltaTime
        sun.direction = simd_float3(0, -1, sin(time))
        light.setPosY(sin(time/2)*30+30)
    }
}
