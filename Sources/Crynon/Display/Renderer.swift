
import MetalKit

var gBTransparency: String = "CRYNON_RENDERER_GBUFFER_TRANSPARENCY"
var gBColor: String = "CRYNON_RENDERER_GBUFFER_COLOR"
var gBPosition: String = "CRYNON_RENDERER_GBUFFER_POSITION"
var gBNormalShadow: String = "CRYNON_RENDERER_GBUFFER_NORMALSHADOW"
var gBDepth: String = "CRYNON_RENDERER_GBUFFER_DEPTH"
var gBMetalRoughAoIOR: String = "CRYNON_RENDERER_GBUFFER_METALROUGHAOIOR"
var gBEmission: String = "CRYNON_RENDERER_GBUFFER_EMISSION"

public class Renderer: NSObject {
    
    static var screenWidth: Float!
    static var screenHeight: Float!
    static var aspectRatio: Float { return screenWidth/screenHeight }
    
    static var currentBlendMode: BlendMode = .Opaque
    static var currentDeltaTime: Float = 0.0
    
    static var time: Float = 0.0
    
    private var optimalTileSize: MTLSize = MTLSizeMake(32, 16, 1)

    var shadowRenderPassDescriptor = MTLRenderPassDescriptor()
    var gBufferRenderPassDescriptor = MTLRenderPassDescriptor()
    var ssaoRenderPassDescriptor = MTLRenderPassDescriptor()
    
    override init() {
        super.init()
        createShadowRenderPassDescriptor()
        createJitterTexture()
    }
    
    func createJitterTexture() {
        let jitterTextureDescriptor = MTLTextureDescriptor()
        jitterTextureDescriptor.textureType = .type3D
        jitterTextureDescriptor.pixelFormat = .rg8Unorm
        jitterTextureDescriptor.width = 64
        jitterTextureDescriptor.height = 512
        jitterTextureDescriptor.depth = 1
        jitterTextureDescriptor.usage = [ .shaderWrite, .shaderRead ]
    
        let jitterTexture = Core.device.makeTexture(descriptor: jitterTextureDescriptor)
        jitterTexture?.label = "JitterTexture"
        AssetLibrary.textures.addTexture(jitterTexture, key: "JitterTexture")
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
    
    func createGBuffer() {
        let bufferTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.metal.pixelFormat,
                                                                              width: Int(Renderer.screenWidth),
                                                                              height: Int(Renderer.screenHeight),
                                                                              mipmapped: false)
        bufferTextureDescriptor.usage = [ .renderTarget, .shaderRead ]
        bufferTextureDescriptor.storageMode = .shared
        
        let TransparencyTexture = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        TransparencyTexture?.label = "GBufferTransparency"
        
        let colorTexture = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        colorTexture?.label = "GBufferColor"
        
        let emissionTexture = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        emissionTexture?.label = "GBufferEmission"

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
        
        gBufferRenderPassDescriptor.colorAttachments[1].clearColor = Preferences.graphics.clearColor
        
        gBufferRenderPassDescriptor.colorAttachments[0].texture = TransparencyTexture
        gBufferRenderPassDescriptor.colorAttachments[1].texture = colorTexture
        gBufferRenderPassDescriptor.colorAttachments[2].texture = positionTexture
        gBufferRenderPassDescriptor.colorAttachments[3].texture = normalShadowTexture
        gBufferRenderPassDescriptor.colorAttachments[4].texture = depthTexture
        gBufferRenderPassDescriptor.colorAttachments[5].texture = metalRoughAoIOR
        gBufferRenderPassDescriptor.colorAttachments[6].texture = emissionTexture
        
        let loadAction = Preferences.graphics.useSkySphere == true ? MTLLoadAction.dontCare : MTLLoadAction.clear
        gBufferRenderPassDescriptor.colorAttachments[0].loadAction = loadAction
        gBufferRenderPassDescriptor.colorAttachments[1].loadAction = loadAction
        gBufferRenderPassDescriptor.colorAttachments[2].loadAction = loadAction
        gBufferRenderPassDescriptor.colorAttachments[3].loadAction = loadAction
        gBufferRenderPassDescriptor.colorAttachments[4].loadAction = loadAction
        gBufferRenderPassDescriptor.colorAttachments[6].loadAction = loadAction
        
        gBufferRenderPassDescriptor.colorAttachments[0].storeAction = .store
        gBufferRenderPassDescriptor.colorAttachments[1].storeAction = .store
        gBufferRenderPassDescriptor.colorAttachments[2].storeAction = .store
        gBufferRenderPassDescriptor.colorAttachments[3].storeAction = .store
        gBufferRenderPassDescriptor.colorAttachments[4].storeAction = .store
        gBufferRenderPassDescriptor.colorAttachments[5].storeAction = .store
        gBufferRenderPassDescriptor.colorAttachments[6].storeAction = .store
        
        AssetLibrary.textures.addTexture(gBufferRenderPassDescriptor.colorAttachments[0].texture, key: gBTransparency)
        AssetLibrary.textures.addTexture(gBufferRenderPassDescriptor.colorAttachments[1].texture, key: gBColor)
        AssetLibrary.textures.addTexture(gBufferRenderPassDescriptor.colorAttachments[2].texture, key: gBPosition)
        AssetLibrary.textures.addTexture(gBufferRenderPassDescriptor.colorAttachments[3].texture, key: gBNormalShadow)
        AssetLibrary.textures.addTexture(gBufferRenderPassDescriptor.colorAttachments[4].texture, key: gBDepth)
        AssetLibrary.textures.addTexture(gBufferRenderPassDescriptor.colorAttachments[5].texture, key: gBMetalRoughAoIOR)
        AssetLibrary.textures.addTexture(gBufferRenderPassDescriptor.colorAttachments[6].texture, key: gBEmission)
        
        //Sets the depth value to 1, so that default depth is infinity
        gBufferRenderPassDescriptor.colorAttachments[4].clearColor = MTLClearColor(red: 1.0, green: 0, blue: 0, alpha: 0)
        
        //Sets the emissive value to 1, so that the sky won't be shaded.
        gBufferRenderPassDescriptor.colorAttachments[6].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        gBufferRenderPassDescriptor.tileWidth = optimalTileSize.width
        gBufferRenderPassDescriptor.tileHeight = optimalTileSize.height
        gBufferRenderPassDescriptor.imageblockSampleLength = GPLibrary.renderPipelineStates[.InitTransparency].imageblockSampleLength
    }
    
    func updateScreenSize(view: MTKView) {
        Renderer.screenWidth = Float((view.bounds.width))*2
        Renderer.screenHeight = Float((view.bounds.height))*2
        if Renderer.screenWidth > 0 && Renderer.screenHeight > 0 {
            createGBuffer()
        }
    }
}

extension Renderer: MTKViewDelegate {
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
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

        guard let drawable = view.currentDrawable, let depthTexture = view.depthStencilTexture else { return }
        gBufferRenderPassDescriptor.depthAttachment.texture = depthTexture
        
        let commandBuffer = Core.commandQueue.makeCommandBuffer()
        commandBuffer?.label = "Main CommandBuffer"
        
        Renderer.currentDeltaTime = 1/Float(view.preferredFramesPerSecond)
        Renderer.time += Renderer.currentDeltaTime
        
        //Update scene
        if SceneManager.inScene() {
            SceneManager.tick(Renderer.currentDeltaTime)
            
            SceneManager.physicsTick(Renderer.currentDeltaTime)
            
            computePass(commandBuffer: commandBuffer)
            
            //Render Shadow Maps
            shadowRenderPass(commandBuffer: commandBuffer)
            
            //Render GBuffer
            gBufferRenderPass(commandBuffer: commandBuffer)
            
            //Composite shaded image
            lightingRenderPass(commandBuffer: commandBuffer, view: view)
        }
    
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }

    func shadowRenderPass(commandBuffer: MTLCommandBuffer!) {
        let shadowRenderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: shadowRenderPassDescriptor)
        shadowRenderCommandEncoder?.label = "Shadow RenderCommandEncoder"
        SceneManager.castShadow(shadowRenderCommandEncoder)
        shadowRenderCommandEncoder?.endEncoding()
    }
    
    func gBufferRenderPass(commandBuffer: MTLCommandBuffer!) {
        let gBufferCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: gBufferRenderPassDescriptor)
        gBufferCommandEncoder?.label = "Deferred RenderCommandEncoder"
        
        gBufferCommandEncoder?.pushDebugGroup("Init imageblocks for transparency")
        gBufferCommandEncoder?.setRenderPipelineState(GPLibrary.renderPipelineStates[.InitTransparency])
        gBufferCommandEncoder?.dispatchThreadsPerTile(optimalTileSize)
        gBufferCommandEncoder?.popDebugGroup()

        gBufferCommandEncoder?.pushDebugGroup("GBuffer fill")
        gBufferCommandEncoder?.pushDebugGroup("Opaque fill")
        Renderer.currentBlendMode = .Opaque
        SceneManager.render(gBufferCommandEncoder)
        gBufferCommandEncoder?.popDebugGroup()
        
        gBufferCommandEncoder?.pushDebugGroup("Alpha rendering")
        Renderer.currentBlendMode = .Alpha
        SceneManager.render(gBufferCommandEncoder)
        gBufferCommandEncoder?.popDebugGroup()
        gBufferCommandEncoder?.popDebugGroup()
        
        gBufferCommandEncoder?.pushDebugGroup("Blending Transparency")
        gBufferCommandEncoder?.setRenderPipelineState(GPLibrary.renderPipelineStates[.TransparentBlending])
        gBufferCommandEncoder?.setDepthStencilState(GPLibrary.depthStencilStates[.NoWriteAlways])
        AssetLibrary.meshes["Quad"].draw(gBufferCommandEncoder)
        gBufferCommandEncoder?.popDebugGroup()
        
        gBufferCommandEncoder?.endEncoding()
    }
    
    func lightingRenderPass(commandBuffer: MTLCommandBuffer!, view: MTKView) {
        let lightingCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!)
        lightingCommandEncoder?.label = "Final RenderCommandEncoder"
        lightingCommandEncoder?.pushDebugGroup("Lighting")
        lightingCommandEncoder?.setRenderPipelineState(GPLibrary.renderPipelineStates[.Lighting])
        lightingCommandEncoder?.setDepthStencilState(GPLibrary.depthStencilStates[.NoWriteAlways])
        lightingCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBTransparency], index: 0)
        lightingCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBColor], index: 1)
        lightingCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBPosition], index: 2)
        lightingCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBNormalShadow], index: 3)
        lightingCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBDepth], index: 4)
        lightingCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBMetalRoughAoIOR], index: 5)
        lightingCommandEncoder?.setFragmentTexture(AssetLibrary.textures[gBEmission], index: 6)
        SceneManager.lightingPass(lightingCommandEncoder)
        AssetLibrary.meshes["Quad"].draw(lightingCommandEncoder)
        lightingCommandEncoder?.popDebugGroup()
        lightingCommandEncoder?.endEncoding()
    }
    
    func computePass(commandBuffer: MTLCommandBuffer!) {
        let computeCommandEncoder = commandBuffer?.makeComputeCommandEncoder()
        computeCommandEncoder?.label = "Main ComputeCommandEncoder"
        
        computeCommandEncoder?.setTexture(AssetLibrary.textures["JitterTexture"], index: 0)
        let texture = AssetLibrary.textures["JitterTexture"]!
        computeCommandEncoder?.setComputePipelineState(GPLibrary.computePipelineStates[.Jitter])
        let groupsPerGrid = MTLSize(width: texture.width, height: texture.height, depth: texture.depth)
        let threadsPerThreadGroup = MTLSize(width: GPLibrary.computePipelineStates[.Jitter].threadExecutionWidth, height: 1, depth: 1)
        computeCommandEncoder?.dispatchThreadgroups(groupsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
        computeCommandEncoder?.endEncoding()
    }
}