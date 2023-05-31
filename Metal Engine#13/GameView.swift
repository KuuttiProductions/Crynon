
import MetalKit
import SwiftUI

struct GameView: NSViewRepresentable {
    
    let renderer: MTKViewDelegate = Renderer()
    
    func updateNSView(_ nsView: MTKView, context: Context) {}
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        
        if let device = MTLCreateSystemDefaultDevice() {
            mtkView.device = device
        }
        
        Core.initialize(device: mtkView.device)
        
        mtkView.delegate = renderer
        
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        
        return mtkView
    }
}
