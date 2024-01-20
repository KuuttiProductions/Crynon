
import MetalKit
import SwiftUI

@available(macOS 10.15, *)
public struct GameView: NSViewRepresentable {
    
    public init() {}
    
    class InputView: MTKView {
        override var acceptsFirstResponder: Bool { true }
        override func keyDown(with event: NSEvent) {}
        override func keyUp(with event: NSEvent) {}
    }
    
    public func updateNSView(_ nsView: MTKView, context: Context) {
        context.coordinator.mtkView(nsView, drawableSizeWillChange: nsView.drawableSize)
    }

    public func makeCoordinator() -> Renderer {
        return Renderer()
    }
    
    public func makeNSView(context: Context) -> MTKView {
        let mtkView = InputView()
    
        if let device = MTLCreateSystemDefaultDevice() {
            mtkView.device = device
        }
        
        mtkView.delegate = context.coordinator
        
        mtkView.colorPixelFormat = Preferences.metal.pixelFormat
        mtkView.depthStencilPixelFormat = Preferences.metal.depthFormat
        mtkView.depthStencilStorageMode = .memoryless
        
        if let fps = Preferences.core.defaultFPS {
            mtkView.preferredFramesPerSecond = fps
        }

        return mtkView
    }
}