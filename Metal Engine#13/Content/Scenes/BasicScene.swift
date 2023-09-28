
import simd

class BasicScene: Scene {
    
    let object = MetameshObject()
    let floor = RigidBody("floor")
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
    let light2 = PointLight()
    let spotlight = Spotlight()
    let physics = RigidBody("physics")
    let physics2 = RigidBody("physics2")
    let skySphere = SkySphere("OceanSky")
    
    var time: Float = 0.0
    
    init() {
        super.init("BasicScene")
        addChild(object)
        addChild(glass)
        addChild(glassF)
        addChild(skySphere)
        addPhysicsObject(floor)
        addCamera(camera, true)
        addChild(cube2)
        addChild(cube3)
        addChild(cube4)
        addChild(grass)
        addChild(glass2)
        addChild(glassH)
        addPhysicsObject(physics)
        addPhysicsObject(physics2)
        addLight(sun)
        addLight(light)
        light.addChild(light2)
        light.addPosX(1)
        addLight(spotlight)
        object.setPosX(-4)
        object.material.shaderMaterial.roughness = 0
        floor.setPos(0, -3, 0)
        floor.setScale(300, 0.2, 10)
        floor.material.shaderMaterial.roughness = 1
        floor.material.shaderMaterial.color = simd_float4(0.2, 0.6, 0.0, 1.0)
        floor.isActive = false
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
        physics.setPos(0, 0, -3, teleport: true)
        physics2.setPos(0.2, 3, -3.1, teleport: true)
        physics.debug_drawCollisionState = true
        physics2.debug_drawCollisionState = true
        sun.lightData.color = simd_float4(1,1,1,1)
        sun.setRotX(Float(45).deg2rad)
        light.setPosY(1)
        sun.lightData.brightness = 0.8
        sun.direction = simd_float3(0, -1, 1)
        light.lightData.brightness = 1.0
        light.lightData.color = simd_float4(0, 1, 1, 1)
        spotlight.setPos(-15, 3, 0)
        spotlight.lightData.color = simd_float4(1,0,0,1)
        floor.material.visible = false
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        time += deltaTime
        sun.direction = simd_float3(sin(time/5), -1, cos(time/5))
        light.setPosY(sin(time)*10+10)
        spotlight.direction = simd_float3(0, sin(time), cos(time))
        glass2.setRotY(time)
    }
}
