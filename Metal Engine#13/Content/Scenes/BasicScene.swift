
import simd

class BasicScene: Scene {
    
    let object = MetameshObject()
    let cube = CubeObject()
    let cube2 = CubeObject()
    let cube3 = CubeObject()
    let cube4 = CubeObject()
    let grass = GameObject("Grass")
    let glass = GameObject("Window")
    let glass2 = GameObject("Window2")
    let camera = FPSCamera()
    let sun = DirectionalLight()
    let light = PointLight()
    let spotlight = Spotlight()
    let physics = RigidBody("Cube")
    
    var time: Float = 0.0
    
    init() {
        super.init("BasicScene")
        addChild(object)
        addChild(cube)
        addChild(cube2)
        addChild(cube3)
        addChild(cube4)
        addChild(grass)
        addChild(glass)
        addChild(glass2)
        addCamera(camera, true)
        addLight(sun)
        addLight(light)
        addLight(spotlight)
        addPhysicsObject(physics)
        object.setPosX(-4)
        cube.setPos(0, -3, 0)
        cube.setScale(300, 0.2, 10)
        cube2.setPosX(20)
        cube2.setScaleY(3)
        cube3.setPos(4, -1, 0)
        cube3.setRotY(Float(30.deg2rad))
        cube4.setPos(-15, 10, 0)
        cube4.setScale(5, 0.3, 5)
        grass.setPos(6, -1.8, 2)
        grass.textureColor = "Grass"
        glass.setPos(9, -1.8, 2)
        glass.textureColor = "Window"
        glass2.setPos(9, -1.8, 4)
        glass2.textureColor = "Window"
        camera.setPosZ(5)
        physics.setPosY(5)
        sun.lightData.color = simd_float4(1,1,1,1)
        sun.setRotX(Float(45).deg2rad)
        light.setPosY(1)
        sun.lightData.brightness = 1.0
        light.lightData.brightness = 1.0
        light.lightData.color = simd_float4(0, 1, 1, 1)
        spotlight.setPos(-15, 3, 0)
        spotlight.lightData.color = simd_float4(1,0,0,1)
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        time += deltaTime
        sun.direction = simd_float3(0, -1, sin(time))
        light.setPosY(sin(time/2)*20+20)
        spotlight.direction = simd_float3(0, sin(time), cos(time))
    }
}
