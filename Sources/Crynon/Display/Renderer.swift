
import MetalKit

var gBTransparency: String = "CRYNON_RENDERER_GBUFFER_TRANSPARENCY"
var gBColor: String = "CRYNON_RENDERER_GBUFFER_COLOR"
var gBPosition: String = "CRYNON_RENDERER_GBUFFER_POSITION"
var gBNormalShadow: String = "CRYNON_RENDERER_GBUFFER_NORMALSHADOW"
var gBDepth: String = "CRYNON_RENDERER_GBUFFER_DEPTH"
var gBMetalRoughAoIOR: String = "CRYNON_RENDERER_GBUFFER_METALROUGHAOIOR"
var gBSSAO: String = "CRYNON_RENDERER_GBUFFER_SSAO"
var jitterTextureStr: String = "CRYNON_RENDERER_JITTER_TEXTURE"
var shadedImage: String = "CRYNON_RENDERER_SHADED"

var bloomThreshold: String = "CRYNON_RENDERER_BLOOM_THRESHOLD"
var bloomA: String = "CRYNON_RENDERER_BLOOM_BLOCK_A"
var bloomB: String = "CRYNON_RENDERER_BLOOM_BLOCK_B"
var bloomC: String = "CRYNON_RENDERER_BLOOM_BLOCK_C"
var bloomD: String = "CRYNON_RENDERER_BLOOM_BLOCK_D"
var bloomE: String = "CRYNON_RENDERER_BLOOM_BLOCK_E"
var bloomF: String = "CRYNON_RENDERER_BLOOM_BLOCK_F"

func lerp(a: Float, b: Float, c: Float)-> Float {
    return a + c * (b - a)
}

public class Renderer: NSObject {
    
    static var screenWidth: Float!
    static var screenHeight: Float!
    static var aspectRatio: Float { return screenWidth/screenHeight }
    static var maxBrightness: Float = 1.0
    
    static var currentRenderState: RenderState = .Opaque
    static var currentDeltaTime: Float = 0.0
    
    static var time: Float = 0.0
    
    private var optimalTileSize: MTLSize = MTLSizeMake(16, 16, 1)

    var shadowRenderPassDescriptor = MTLRenderPassDescriptor()
    var opaqueRenderPassDescriptor = MTLRenderPassDescriptor()
    var transparencyRenderPassDescriptor = MTLRenderPassDescriptor()
    var SSAORenderPassDescriptor = MTLRenderPassDescriptor()
    var lightingRenderPassDescriptor = MTLRenderPassDescriptor()
    
    var SSAOSampleKernel: MTLBuffer!
    static var viewMatrix: simd_float4x4!
    static var projectionMatrix: simd_float4x4!
    
    override init() {
        super.init()
        createShadowRenderPassDescriptor()
        createJitterTexture()
        createSSAOSampleKernel()
    }
    
    func createSSAOSampleKernel() {
        var samples: [simd_float3] = []
        for i in 0..<64 {
            var sample = simd_float3(Float.random(in: -1.0...1.0),
                                     Float.random(in: -1.0...1.0),
                                     Float.random(in: 0.0...1.0))
            sample = normalize(sample)
            var scale = Float(i) / 64.0
            scale = lerp(a: 0.1, b: 1.0, c: scale * scale)
            sample *= scale
            samples.append(sample)
        }
        SSAOSampleKernel = Core.device.makeBuffer(bytes: samples, length: simd_float3.stride(count: 64))!
        SSAOSampleKernel.label = "SSAO Sample Kernel Buffer"
    }
    
    func createJitterTexture() {
        let jitterTextureDescriptor = MTLTextureDescriptor()
        jitterTextureDescriptor.textureType = .type2D
        jitterTextureDescriptor.pixelFormat = .rg8Snorm
        jitterTextureDescriptor.width = 4
        jitterTextureDescriptor.height = 4
        jitterTextureDescriptor.usage = [ .shaderWrite, .shaderRead ]
    
        let jitterTexture = Core.device.makeTexture(descriptor: jitterTextureDescriptor)
        jitterTexture?.label = "JitterTexture"
        AssetLibrary.textures.addTexture(jitterTexture, key: jitterTextureStr)
    }
    
    func createShadowRenderPassDescriptor() {
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.metal.depthFormat,
                                                                              width: Preferences.graphics.shadowMapResolution,
                                                                              height: Preferences.graphics.shadowMapResolution,
                                                                              mipmapped: false)
        depthTextureDescriptor.usage = [ .renderTarget, .shaderRead ]
        let depthTexture = Core.device.makeTexture(descriptor: depthTextureDescriptor)
        depthTexture?.label = "ShadowMap1"
        AssetLibrary.textures.addTexture(depthTexture, key: "ShadowMap1")
        
        shadowRenderPassDescriptor.depthAttachment.texture = AssetLibrary.textures["ShadowMap1"]
        shadowRenderPassDescriptor.depthAttachment.loadAction = .clear
        shadowRenderPassDescriptor.depthAttachment.storeAction = .store
    }
    
    func createOpaqueRenderPassDescriptor() {
        let bufferTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.metal.pixelFormat,
                                                                               width: Int(Renderer.screenWidth),
                                                                               height: Int(Renderer.screenHeight),
                                                                               mipmapped: false)
        bufferTextureDescriptor.usage = [ .renderTarget, .shaderRead ]
        bufferTextureDescriptor.storageMode = .shared
        
        let colorTexture = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        colorTexture?.label = "GBufferColor"

        bufferTextureDescriptor.pixelFormat = Preferences.metal.floatPixelFormat
        let positionTexture = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        positionTexture?.label = "GBufferPosition"
        
        bufferTextureDescriptor.pixelFormat = Preferences.metal.signedPixelFormat
        let normalShadowTexture = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        normalShadowTexture?.label = "GBufferNormalShadow"
        
        bufferTextureDescriptor.pixelFormat = .r32Float
        let depthTexture = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        depthTexture?.label = "GBufferDepth"
        
        bufferTextureDescriptor.pixelFormat = Preferences.metal.pixelFormat
        let metalRoughAoIOR = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        metalRoughAoIOR?.label = "GBufferMetalRoughAoIOR"
        
        opaqueRenderPassDescriptor.colorAttachments[1].clearColor = Preferences.graphics.clearColor
        
        opaqueRenderPassDescriptor.colorAttachments[1].texture = colorTexture
        opaqueRenderPassDescriptor.colorAttachments[2].texture = positionTexture
        opaqueRenderPassDescriptor.colorAttachments[3].texture = normalShadowTexture
        opaqueRenderPassDescriptor.colorAttachments[4].texture = depthTexture
        opaqueRenderPassDescriptor.colorAttachments[5].texture = metalRoughAoIOR
        
        let loadAction = Preferences.graphics.useSkySphere == true ? MTLLoadAction.dontCare : MTLLoadAction.clear
        opaqueRenderPassDescriptor.colorAttachments[1].loadAction = loadAction
        opaqueRenderPassDescriptor.colorAttachments[2].loadAction = loadAction
        opaqueRenderPassDescriptor.colorAttachments[3].loadAction = loadAction
        opaqueRenderPassDescriptor.colorAttachments[4].loadAction = loadAction
        
        opaqueRenderPassDescriptor.colorAttachments[0].storeAction = .store
        opaqueRenderPassDescriptor.colorAttachments[1].storeAction = .store
        opaqueRenderPassDescriptor.colorAttachments[2].storeAction = .store
        opaqueRenderPassDescriptor.colorAttachments[3].storeAction = .store
        opaqueRenderPassDescriptor.colorAttachments[4].storeAction = .store
        opaqueRenderPassDescriptor.colorAttachments[5].storeAction = .store
        opaqueRenderPassDescriptor.depthAttachment.storeAction = .store
        
        AssetLibrary.textures.addTexture(opaqueRenderPassDescriptor.colorAttachments[1].texture, key: gBColor)
        AssetLibrary.textures.addTexture(opaqueRenderPassDescriptor.colorAttachments[2].texture, key: gBPosition)
        AssetLibrary.textures.addTexture(opaqueRenderPassDescriptor.colorAttachments[3].texture, key: gBNormalShadow)
        AssetLibrary.textures.addTexture(opaqueRenderPassDescriptor.colorAttachments[4].texture, key: gBDepth)
        AssetLibrary.textures.addTexture(opaqueRenderPassDescriptor.colorAttachments[5].texture, key: gBMetalRoughAoIOR)
        
        //Sets the depth value to 1, so that default depth is infinity
        opaqueRenderPassDescriptor.colorAttachments[4].clearColor = MTLClearColor(red: 1.0, green: 0, blue: 0, alpha: 0)
        
        //Sets the emissive value to 1, so that the sky won't be shaded.
        opaqueRenderPassDescriptor.colorAttachments[1].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    }
    
    func createTransparencyRenderPassDescriptor() {
        let bufferTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.metal.pixelFormat,
                                                                               width: Int(Renderer.screenWidth),
                                                                               height: Int(Renderer.screenHeight),
                                                                               mipmapped: false)
        bufferTextureDescriptor.usage = [ .renderTarget, .shaderRead ]
        bufferTextureDescriptor.storageMode = .shared
        
        let TransparencyTexture = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        TransparencyTexture?.label = "GBufferTransparency"
        
        let loadAction = Preferences.graphics.useSkySphere == true ? MTLLoadAction.dontCare : MTLLoadAction.clear
        transparencyRenderPassDescriptor.colorAttachments[0].texture = TransparencyTexture
        transparencyRenderPassDescriptor.colorAttachments[0].loadAction = loadAction
        transparencyRenderPassDescriptor.colorAttachments[0].storeAction = .store
        transparencyRenderPassDescriptor.depthAttachment.loadAction = .load
        AssetLibrary.textures.addTexture(transparencyRenderPassDescriptor.colorAttachments[0].texture, key: gBTransparency)
        
        transparencyRenderPassDescriptor.tileWidth = optimalTileSize.width
        transparencyRenderPassDescriptor.tileHeight = optimalTileSize.height
        transparencyRenderPassDescriptor.imageblockSampleLength = GPLibrary.renderPipelineStates[.InitTransparency].imageblockSampleLength
    }
    
    func createSSAORenderPassDescriptor() {
        let bufferTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r32Float,
                                                                               width: Int(Renderer.screenWidth),
                                                                               height: Int(Renderer.screenHeight),
                                                                               mipmapped: false)
        bufferTextureDescriptor.usage = [ .renderTarget, .shaderRead ]
        bufferTextureDescriptor.storageMode = .shared
        let ssaoTexture = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        ssaoTexture?.label = "gBufferSSAO"
        SSAORenderPassDescriptor.colorAttachments[0].texture = ssaoTexture
        SSAORenderPassDescriptor.colorAttachments[0].storeAction = .store
        AssetLibrary.textures.addTexture(SSAORenderPassDescriptor.colorAttachments[0].texture, key: gBSSAO)
    }
    
    func createLightingRenderPassDescriptor() {
        let bufferTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.metal.pixelFormat,
                                                                               width: Int(Renderer.screenWidth),
                                                                               height: Int(Renderer.screenHeight),
                                                                               mipmapped: false)
        bufferTextureDescriptor.usage = [ .renderTarget, .shaderRead]
        bufferTextureDescriptor.storageMode = .shared
        let lightingTexture = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        lightingTexture?.label = "Lighting texture"
        
        lightingRenderPassDescriptor.colorAttachments[0].texture = lightingTexture
        lightingRenderPassDescriptor.colorAttachments[0].storeAction = .store
        AssetLibrary.textures.addTexture(lightingRenderPassDescriptor.colorAttachments[0].texture, key: shadedImage)
    }
    
    func createBloomTextures() {
        let bufferTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.metal.pixelFormat,
                                                                               width: Int(Renderer.screenWidth),
                                                                               height: Int(Renderer.screenHeight),
                                                                               mipmapped: false)
        bufferTextureDescriptor.usage = [ .shaderWrite, .shaderRead ]
        
        let bloomTexture = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        bloomTexture?.label = "Bloom threshold texture"
        
        bufferTextureDescriptor.width = Int(Renderer.screenWidth) / 2
        bufferTextureDescriptor.height = Int(Renderer.screenHeight) / 2
        let bloomTextureA = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        bloomTextureA?.label = "Bloom block A"
        
        bufferTextureDescriptor.width = Int(Renderer.screenWidth) / 4
        bufferTextureDescriptor.height = Int(Renderer.screenHeight) / 4
        let bloomTextureB = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        bloomTextureB?.label = "Bloom block B"

        bufferTextureDescriptor.width = Int(Renderer.screenWidth) / 8
        bufferTextureDescriptor.height = Int(Renderer.screenHeight) / 8
        let bloomTextureC = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        bloomTextureC?.label = "Bloom block C"
        
        bufferTextureDescriptor.width = Int(Renderer.screenWidth) / 16
        bufferTextureDescriptor.height = Int(Renderer.screenHeight) / 16
        let bloomTextureD = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        bloomTextureD?.label = "Bloom block D"
        
        bufferTextureDescriptor.width = Int(Renderer.screenWidth) / 32
        bufferTextureDescriptor.height = Int(Renderer.screenHeight) / 32
        let bloomTextureE = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        bloomTextureE?.label = "Bloom block E"
        
        bufferTextureDescriptor.width = Int(Renderer.screenWidth) / 64
        bufferTextureDescriptor.height = Int(Renderer.screenHeight) / 64
        let bloomTextureF = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        bloomTextureF?.label = "Bloom block F"
        
        AssetLibrary.textures.addTexture(bloomTexture, key: bloomThreshold)
        AssetLibrary.textures.addTexture(bloomTextureA, key: bloomA)
        AssetLibrary.textures.addTexture(bloomTextureB, key: bloomB)
        AssetLibrary.textures.addTexture(bloomTextureC, key: bloomC)
        AssetLibrary.textures.addTexture(bloomTextureD, key: bloomD)
        AssetLibrary.textures.addTexture(bloomTextureE, key: bloomE)
        AssetLibrary.textures.addTexture(bloomTextureF, key: bloomF)
    }
    
    func updateScreenSize(view: MTKView) {
        Renderer.screenWidth = Float((view.bounds.width))*2
        Renderer.screenHeight = Float((view.bounds.height))*2
        if Renderer.screenWidth > 0 && Renderer.screenHeight > 0 {
            createOpaqueRenderPassDescriptor()
            createTransparencyRenderPassDescriptor()
            createSSAORenderPassDescriptor()
            createLightingRenderPassDescriptor()
            createBloomTextures()
        }
    }
}

extension Renderer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        maxBrightnessValueChecking()
        updateScreenSize(view: view)
        if let fps = view.window?.screen?.maximumFramesPerSecond {
            view.preferredFramesPerSecond = fps
        }
    }
    
    public func draw(in view: MTKView) {
        if Core.paused {
            return
        }
        if let fps =  Preferences.core.defaultFPS {
            view.preferredFramesPerSecond = fps
        }

        guard let drawable = view.currentDrawable, let depth = view.depthStencilTexture else { return }
        opaqueRenderPassDescriptor.depthAttachment.texture = depth
        transparencyRenderPassDescriptor.depthAttachment.texture = depth
        drawable.layer.wantsExtendedDynamicRangeContent = Preferences.graphics.outputHDR
        
        let commandBuffer = Core.commandQueue.makeCommandBuffer()
        commandBuffer?.label = "Main CommandBuffer"
        
        Renderer.currentDeltaTime = 1/Float(view.preferredFramesPerSecond)
        Renderer.time += Renderer.currentDeltaTime
        
        //Update scene
        if SceneManager.inScene() {
            SceneManager.tick(Renderer.currentDeltaTime)
            
            SceneManager.physicsTick(Renderer.currentDeltaTime)
            
            InputManager.update()
            
            computePass(commandBuffer: commandBuffer)
            
            // Render Shadow Maps
            shadowRenderPass(commandBuffer: commandBuffer)
            
            // Render GBuffer
            opaqueRenderPass(commandBuffer: commandBuffer)
            transparentRenderPass(commandBuffer: commandBuffer)
            
            if Preferences.graphics.useSSAO {
                //Render Screen Space Ambient Occlusion
                SSAORenderPass(commandBuffer: commandBuffer)
            }

            // Composite shaded image
            lightingRenderPass(commandBuffer: commandBuffer)
            
            if Preferences.graphics.useBloom {
                bloomPass(commandBuffer: commandBuffer)
            }
            
            // Post-processing
            compositingRenderPass(commandBuffer: commandBuffer!, view: view)
        }
    
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }

    func shadowRenderPass(commandBuffer: MTLCommandBuffer!) {
        let shadowRenderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: shadowRenderPassDescriptor)
        shadowRenderCommandEncoder?.label = "Shadow RenderCommandEncoder"
        Renderer.currentRenderState = .Shadow
        SceneManager.castShadow(shadowRenderCommandEncoder)
        shadowRenderCommandEncoder?.endEncoding()
    }
    
    func opaqueRenderPass(commandBuffer: MTLCommandBuffer!) {
        let opaqueCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: opaqueRenderPassDescriptor)
        opaqueCommandEncoder?.label = "Opaque RenderCommandEncoder"

        var screenSize = simd_float2(Renderer.screenWidth, Renderer.screenHeight);
        opaqueCommandEncoder?.setFragmentBytes(&screenSize, length: simd_float2.stride, index: 5)
        opaqueCommandEncoder?.setFragmentTexture(AssetLibrary.textures[jitterTextureStr], index: 9)
        opaqueCommandEncoder?.pushDebugGroup("Opaque fill")
        Renderer.currentRenderState = .Opaque
        SceneManager.render(opaqueCommandEncoder)
        opaqueCommandEncoder?.popDebugGroup()
        opaqueCommandEncoder?.endEncoding()
    }
    
    func transparentRenderPass(commandBuffer: MTLCommandBuffer!) {
        let transparencyCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: transparencyRenderPassDescriptor)
        transparencyCommandEncoder?.label = "Transparency RenderCommandEncoder"
        
        var screenSize = simd_float2(Renderer.screenWidth, Renderer.screenHeight);
        transparencyCommandEncoder?.setFragmentBytes(&screenSize, length: simd_float2.stride, index: 5)
        transparencyCommandEncoder?.pushDebugGroup("Init imageblocks for transparency")
        transparencyCommandEncoder?.setRenderPipelineState(GPLibrary.renderPipelineStates[.InitTransparency])
        transparencyCommandEncoder?.dispatchThreadsPerTile(optimalTileSize)
        transparencyCommandEncoder?.popDebugGroup()
        transparencyCommandEncoder?.pushDebugGroup("Alpha rendering")
        Renderer.currentRenderState = .Alpha
        SceneManager.render(transparencyCommandEncoder)
        transparencyCommandEncoder?.popDebugGroup()
        
        transparencyCommandEncoder?.pushDebugGroup("Blending Transparency")
        transparencyCommandEncoder?.setRenderPipelineState(GPLibrary.renderPipelineStates[.TransparentBlending])
        transparencyCommandEncoder?.setDepthStencilState(GPLibrary.depthStencilStates[.NoWriteAlways])
        AssetLibrary.meshes["Quad"].plainDraw(transparencyCommandEncoder)
        transparencyCommandEncoder?.popDebugGroup()
        transparencyCommandEncoder?.endEncoding()
    }
    
    func SSAORenderPass(commandBuffer: MTLCommandBuffer!) {
        let SSAOCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: SSAORenderPassDescriptor)
        var screenSize = simd_float2(Renderer.screenWidth, Renderer.screenHeight);
        SSAOCommandEncoder?.label = "SSAO RenderCommandEncoder"
        SSAOCommandEncoder?.pushDebugGroup("Rendering SSAO")
        SSAOCommandEncoder?.setRenderPipelineState(GPLibrary.renderPipelineStates[.SSAO])
        SSAOCommandEncoder?.setFragmentBuffer(SSAOSampleKernel, offset: simd_float3.stride, index: 0)
        SSAOCommandEncoder?.setFragmentBytes(&screenSize, length: simd_float2.stride, index: 1)
        SSAOCommandEncoder?.setFragmentBytes(&Renderer.projectionMatrix, length: simd_float4x4.stride, index: 2)
        SSAOCommandEncoder?.setFragmentBytes(&Renderer.viewMatrix, length: simd_float4x4.stride, index: 3)
        SSAOCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBNormalShadow], index: 0)
        SSAOCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBPosition], index: 1)
        SSAOCommandEncoder?.setFragmentTexture(AssetLibrary.textures[jitterTextureStr], index: 2)
        AssetLibrary.meshes["Quad"].plainDraw(SSAOCommandEncoder)
        SSAOCommandEncoder?.popDebugGroup()
        SSAOCommandEncoder?.endEncoding()
    }
    
    func lightingRenderPass(commandBuffer: MTLCommandBuffer!) {
        let lightingCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: lightingRenderPassDescriptor)
        lightingCommandEncoder?.label = "Lighting RenderCommandEncoder"
        lightingCommandEncoder?.pushDebugGroup("Lighting")
        lightingCommandEncoder?.setRenderPipelineState(GPLibrary.renderPipelineStates[.Lighting])
        lightingCommandEncoder?.setDepthStencilState(GPLibrary.depthStencilStates[.NoWriteAlways])
        lightingCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBTransparency], index: 0)
        lightingCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBColor], index: 1)
        lightingCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBPosition], index: 2)
        lightingCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBNormalShadow], index: 3)
        lightingCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBDepth], index: 4)
        lightingCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBMetalRoughAoIOR], index: 5)
        if Preferences.graphics.useSSAO { lightingCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBSSAO], index: 6) }
        SceneManager.lightingPass(lightingCommandEncoder)
        var screenSize = simd_float2(Renderer.screenWidth, Renderer.screenHeight);
        lightingCommandEncoder?.setFragmentBytes(&screenSize, length: simd_float2.stride, index: 5)
        AssetLibrary.meshes["Quad"].plainDraw(lightingCommandEncoder)
        lightingCommandEncoder?.popDebugGroup()
        lightingCommandEncoder?.endEncoding()
    }
    
    func bloomPass(commandBuffer: MTLCommandBuffer!) {
        var bloomCommandEncoder = commandBuffer.makeComputeCommandEncoder()
        bloomCommandEncoder?.label = "Bloom ComputeCommandEncoder"
        let shadedImage = AssetLibrary.textures[shadedImage]!

        // Bloom threshold
        bloomCommandEncoder?.setComputePipelineState(GPLibrary.computePipelineStates[.BloomThreshold])
        bloomCommandEncoder?.pushDebugGroup("Adding Bloom threshold")
        bloomCommandEncoder?.setTexture(shadedImage, index: 0)
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomThreshold], index: 1)
        bloomCommandEncoder?.setBytes(&Preferences.graphics.bloomThreshold, length: Float.stride, index: 0)
        var groupsPerGrid = MTLSize(width: shadedImage.width, height: shadedImage.height, depth: 1)
        bloomCommandEncoder?.dispatchThreadgroups(groupsPerGrid,
                                                  threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
        bloomCommandEncoder?.popDebugGroup()
        
        // Downsampling A
        bloomCommandEncoder?.setComputePipelineState(GPLibrary.computePipelineStates[.BloomDownsample])
        bloomCommandEncoder?.pushDebugGroup("Downsampling to Bloom Block A")
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomThreshold], index: 0)
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomA], index: 1)
        groupsPerGrid = MTLSize(width: shadedImage.width / 2, height: shadedImage.height / 2, depth: 1)
        var screenSize = simd_uint2(simd_float2(Float(shadedImage.width / 2), Float(shadedImage.height / 2)))
        bloomCommandEncoder?.setBytes(&screenSize, length: simd_uint2.stride, index: 0)
        bloomCommandEncoder?.dispatchThreadgroups(groupsPerGrid,
                                                  threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
        bloomCommandEncoder?.popDebugGroup()
        // Downsampling B
        bloomCommandEncoder?.pushDebugGroup("Downsampling to Bloom Block B")
        screenSize = screenSize / 2
        bloomCommandEncoder?.setBytes(&screenSize, length: simd_uint2.stride, index: 0)
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomA], index: 0)
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomB], index: 1)
        groupsPerGrid = MTLSize(width: shadedImage.width / 4, height: shadedImage.height / 4, depth: 1)
        screenSize = simd_uint2(simd_float2(Float(shadedImage.width / 4), Float(shadedImage.height / 4)))
        bloomCommandEncoder?.setBytes(&screenSize, length: simd_uint2.stride, index: 0)
        bloomCommandEncoder?.dispatchThreadgroups(groupsPerGrid,
                                                  threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
        bloomCommandEncoder?.popDebugGroup()
        // Downsampling C
        bloomCommandEncoder?.pushDebugGroup("Downsampling to Bloom Block C")
        screenSize = screenSize / 2
        bloomCommandEncoder?.setBytes(&screenSize, length: simd_uint2.stride, index: 0)
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomB], index: 0)
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomC], index: 1)
        groupsPerGrid = MTLSize(width: shadedImage.width / 8, height: shadedImage.height / 8, depth: 1)
        screenSize = simd_uint2(simd_float2(Float(shadedImage.width / 8), Float(shadedImage.height / 8)))
        bloomCommandEncoder?.setBytes(&screenSize, length: simd_uint2.stride, index: 0)
        bloomCommandEncoder?.dispatchThreadgroups(groupsPerGrid,
                                                  threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
        bloomCommandEncoder?.popDebugGroup()
        // Downsampling D
        bloomCommandEncoder?.pushDebugGroup("Downsampling to Bloom Block D")
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomC], index: 0)
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomD], index: 1)
        groupsPerGrid = MTLSize(width: shadedImage.width / 16, height: shadedImage.height / 16, depth: 1)
        screenSize = simd_uint2(simd_float2(Float(shadedImage.width / 16), Float(shadedImage.height / 16)))
        bloomCommandEncoder?.setBytes(&screenSize, length: simd_uint2.stride, index: 0)
        bloomCommandEncoder?.dispatchThreadgroups(groupsPerGrid,
                                                  threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
        bloomCommandEncoder?.popDebugGroup()
        // Downsampling E
        bloomCommandEncoder?.pushDebugGroup("Downsampling to Bloom Block E")
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomD], index: 0)
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomE], index: 1)
        groupsPerGrid = MTLSize(width: shadedImage.width / 32, height: shadedImage.height / 32, depth: 1)
        screenSize = simd_uint2(simd_float2(Float(shadedImage.width / 32), Float(shadedImage.height / 32)))
        bloomCommandEncoder?.setBytes(&screenSize, length: simd_uint2.stride, index: 0)
        bloomCommandEncoder?.dispatchThreadgroups(groupsPerGrid,
                                                  threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
        bloomCommandEncoder?.popDebugGroup()
        // Downsampling F
        bloomCommandEncoder?.pushDebugGroup("Downsampling to Bloom Block F")
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomE], index: 0)
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomF], index: 1)
        groupsPerGrid = MTLSize(width: shadedImage.width / 64, height: shadedImage.height / 64, depth: 1)
        screenSize = simd_uint2(simd_float2(Float(shadedImage.width / 64), Float(shadedImage.height / 64)))
        bloomCommandEncoder?.setBytes(&screenSize, length: simd_uint2.stride, index: 0)
        bloomCommandEncoder?.dispatchThreadgroups(groupsPerGrid,
                                                  threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
        bloomCommandEncoder?.popDebugGroup()
        // Upsampling and blurring
        var blockF = AssetLibrary.textures[bloomF]!
        bloomCommandEncoder?.setComputePipelineState(GPLibrary.computePipelineStates[.BloomUpsample])
        bloomCommandEncoder?.pushDebugGroup("Upsampling to Bloom Block E")
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomF], index: 0)
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomE], index: 1)
        groupsPerGrid = MTLSize(width: shadedImage.width / 32, height: shadedImage.height / 32, depth: 1)
        screenSize = simd_uint2(simd_float2(Float(blockF.width * 2), Float(blockF.height * 2)))
        bloomCommandEncoder?.setBytes(&screenSize, length: simd_uint2.stride, index: 0)
        bloomCommandEncoder?.dispatchThreadgroups(groupsPerGrid,
                                                  threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
        bloomCommandEncoder?.popDebugGroup()
        bloomCommandEncoder?.pushDebugGroup("Upsampling to Bloom Block D")
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomE], index: 0)
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomD], index: 1)
        groupsPerGrid = MTLSize(width: shadedImage.width / 16, height: shadedImage.height / 16, depth: 1)
        screenSize = simd_uint2(simd_float2(Float(blockF.width * 4), Float(blockF.height * 4)))
        bloomCommandEncoder?.setBytes(&screenSize, length: simd_uint2.stride, index: 0)
        bloomCommandEncoder?.dispatchThreadgroups(groupsPerGrid,
                                                  threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
        bloomCommandEncoder?.popDebugGroup()
        bloomCommandEncoder?.pushDebugGroup("Upsampling to Bloom Block C")
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomD], index: 0)
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomC], index: 1)
        groupsPerGrid = MTLSize(width: shadedImage.width / 8, height: shadedImage.height / 8, depth: 1)
        screenSize = simd_uint2(simd_float2(Float(blockF.width * 8), Float(blockF.height * 8)))
        bloomCommandEncoder?.setBytes(&screenSize, length: simd_uint2.stride, index: 0)
        bloomCommandEncoder?.dispatchThreadgroups(groupsPerGrid,
                                                  threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
        bloomCommandEncoder?.popDebugGroup()
        bloomCommandEncoder?.pushDebugGroup("Upsampling to Bloom Block B")
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomC], index: 0)
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomB], index: 1)
        groupsPerGrid = MTLSize(width: shadedImage.width / 4, height: shadedImage.height / 4, depth: 1)
        screenSize = simd_uint2(simd_float2(Float(blockF.width * 16), Float(blockF.height * 16)))
        bloomCommandEncoder?.setBytes(&screenSize, length: simd_uint2.stride, index: 0)
        bloomCommandEncoder?.dispatchThreadgroups(groupsPerGrid,
                                                  threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
        bloomCommandEncoder?.popDebugGroup()
        bloomCommandEncoder?.pushDebugGroup("Upsampling to Bloom Block A")
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomB], index: 0)
        bloomCommandEncoder?.setTexture(AssetLibrary.textures[bloomA], index: 1)
        groupsPerGrid = MTLSize(width: shadedImage.width / 2, height: shadedImage.height / 2, depth: 1)
        screenSize = simd_uint2(simd_float2(Float(blockF.width * 32), Float(blockF.height * 32)))
        bloomCommandEncoder?.setBytes(&screenSize, length: simd_uint2.stride, index: 0)
        bloomCommandEncoder?.dispatchThreadgroups(groupsPerGrid,
                                                  threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
        bloomCommandEncoder?.popDebugGroup()

        bloomCommandEncoder?.popDebugGroup()
        bloomCommandEncoder?.endEncoding()
    }
    
    func compositingRenderPass(commandBuffer: MTLCommandBuffer, view: MTKView) {
        let compositingRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!)
        var constants = CompositionConstant()
        constants.bloomIntensity = Preferences.graphics.bloomIntensity
        compositingRenderCommandEncoder?.label = "Compositing RenderCommandEncoder"
        compositingRenderCommandEncoder?.setRenderPipelineState(GPLibrary.renderPipelineStates[.Compositing])
        compositingRenderCommandEncoder?.setFragmentBytes(&constants, length: CompositionConstant.stride, index: 0)
        compositingRenderCommandEncoder?.setFragmentTexture(AssetLibrary.textures[shadedImage], index: 0)
        compositingRenderCommandEncoder?.setFragmentTexture(AssetLibrary.textures[bloomA], index: 1)
        AssetLibrary.meshes["Quad"].plainDraw(compositingRenderCommandEncoder)
        compositingRenderCommandEncoder!.endEncoding()
    }
    
    func computePass(commandBuffer: MTLCommandBuffer!) {
        let computeCommandEncoder = commandBuffer?.makeComputeCommandEncoder()
        computeCommandEncoder?.label = "Main ComputeCommandEncoder"
        computeCommandEncoder?.setTexture(AssetLibrary.textures[jitterTextureStr], index: 0)
        computeCommandEncoder?.setBytes(&Renderer.time, length: Float.stride, index: 0)
        let texture = AssetLibrary.textures[jitterTextureStr]!
        computeCommandEncoder?.setComputePipelineState(GPLibrary.computePipelineStates[.Jitter])
        let groupsPerGrid = MTLSize(width: texture.width, height: texture.height, depth: texture.depth)
        let threadsPerThreadGroup = MTLSize(width: GPLibrary.computePipelineStates[.Jitter].threadExecutionWidth, height: 1, depth: 1)
        computeCommandEncoder?.dispatchThreadgroups(groupsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
        computeCommandEncoder?.endEncoding()
    }
}

extension Renderer {
    func maxBrightnessValueChecking() {
        NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification,
                                               object: nil,
                                               queue: nil) { info in
            if Preferences.graphics.outputHDR {
                Renderer.maxBrightness = Float(NSScreen.main!.maximumExtendedDynamicRangeColorComponentValue)
            } else {
                Renderer.maxBrightness = 1.0
            }
        }
    }
}
