
import MetalKit
import SwiftUI

struct GameView: NSViewRepresentable {
    
    func updateNSView(_ nsView: MTKView, context: Context) {}
    
    func makeCoordinator() -> Renderer {
        return Renderer()
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
    
        if let device = MTLCreateSystemDefaultDevice() {
            mtkView.device = device
        }
        
        mtkView.delegate = context.coordinator
        
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.1, blue: 0.7, alpha: 1.0)

        return mtkView
    }
}
