
import simd

class BasicScene: Scene {
    
    let object = MetameshObject()
    let cube = CubeObject()
    let cube2 = CubeObject()
    let cube3 = CubeObject()
    let cube4 = CubeObject()
    let grass = GameObject("Grass")
    let glass = GameObject("Window")
    let glassF = GameObject("WindowF")
    let glassH = GameObject("WindowH")
    let glass2 = GameObject("Window2")
    let glass3 = GameObject("Window3")
    let camera = FPSCamera()
    let sun = DirectionalLight()
    let light = PointLight()
    let spotlight = Spotlight()
    let physics = RigidBody("Cube")
    let skySphere = SkySphere("OceanSky")
    
    var time: Float = 0.0
    
    init() {
        super.init("BasicScene")
        addChild(object)
        addChild(glass)
        addChild(glassF)
        addChild(skySphere)
        addChild(cube)
        addChild(cube2)
        addChild(cube3)
        addChild(cube4)
        addChild(grass)
        addChild(glass2)
        addChild(glassH)
        addCamera(camera, true)
        addLight(sun)
        //addLight(light)
        addLight(spotlight)
        addPhysicsObject(physics)
        object.setPosX(-4)
        object.material.shaderMaterial.roughness = 0
        cube.setPos(0, -3, 0)
        cube.setScale(300, 0.2, 10)
        cube.material.shaderMaterial.roughness = 1
        cube2.setPosX(20)
        cube2.setScaleY(3)
        cube3.setPos(4, -1, 0)
        cube3.setRotY(Float(30.deg2rad))
        cube4.setPos(-15, 10, 0)
        cube4.setScale(5, 0.3, 5)
        grass.setPos(6, -1.8, 2)
        grass.material.textureColor = "Grass"
        glass.setPos(5, -1.8, 5)
        glass.material.textureColor = "Window"
        glassF.setPos(5, -1.8, 4)
        glassF.material.textureColor = "Window"
        glassH.setPos(5, -1.8, 3)
        glassH.material.textureColor = "Window"
        glass2.setPos(9, -1.5, 2)
        glass2.material.textureColor = "Window"
        glass2.addChild(glass3)
        glass3.setPos(2, 0, 0)
        glass3.material.textureColor = "Window"
        glassH.material.shader = .Transparent
        glassF.material.shader = .Transparent
        glass.material.shader = .Transparent
        glass2.material.shader = .Transparent
        glass3.material.shader = .Transparent
        glassH.material.blendMode = .Alpha
        glassF.material.blendMode = .Alpha
        glass.material.blendMode = .Alpha
        glass2.material.blendMode = .Alpha
        glass3.material.blendMode = .Alpha
        camera.setPosZ(5)
        physics.setPosY(5)
        sun.lightData.color = simd_float4(1,1,1,1)
        sun.setRotX(Float(45).deg2rad)
        light.setPosY(1)
        sun.lightData.brightness = 0.8
        light.lightData.brightness = 1.0
        light.lightData.color = simd_float4(0, 1, 1, 1)
        spotlight.setPos(-15, 3, 0)
        spotlight.lightData.color = simd_float4(1,0,0,1)
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        time += deltaTime
        sun.direction = simd_float3(0, -1, sin(time))
        light.setPosY(sin(time)*10+10)
        spotlight.direction = simd_float3(0, sin(time), cos(time))
        glass2.setRotY(time)
    }
}
