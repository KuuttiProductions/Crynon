
import MetalKit
import SwiftUI

struct GameView: NSViewRepresentable {
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        context.coordinator.mtkView(nsView, drawableSizeWillChange: nsView.drawableSize)
    }
    
    //Make Renderer class
    //Called ´coordinator´ for some reason
    func makeCoordinator() -> Renderer {
        return Renderer()
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
    
        if let device = MTLCreateSystemDefaultDevice() {
            mtkView.device = device
        }
        
        mtkView.delegate = context.coordinator
        
        mtkView.colorPixelFormat = Preferences.pixelFormat
        mtkView.clearColor = Preferences.clearColor

        return mtkView
    }
}
