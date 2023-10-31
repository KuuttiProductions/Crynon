
import MetalKit
import SwiftUI

@available(macOS 10.15, *)
struct GameView: NSViewRepresentable {
    
    class InputView: MTKView {
        override var acceptsFirstResponder: Bool { true }
        override func keyDown(with event: NSEvent) {}
        override func keyUp(with event: NSEvent) {}
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        context.coordinator.mtkView(nsView, drawableSizeWillChange: nsView.drawableSize)
    }

    func makeCoordinator() -> Renderer {
        return Renderer()
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = InputView()
    
        if let device = MTLCreateSystemDefaultDevice() {
            mtkView.device = device
        }
        
        mtkView.delegate = context.coordinator
        
        mtkView.colorPixelFormat = Preferences.pixelFormat
        mtkView.depthStencilPixelFormat = Preferences.depthFormat
        
        mtkView.preferredFramesPerSecond = Preferences.preferredFPS
        
        return mtkView
    }
}
