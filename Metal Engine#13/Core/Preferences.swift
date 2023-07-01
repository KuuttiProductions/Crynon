
import MetalKit

class Preferences {
    public static var pixelFormat: MTLPixelFormat = .bgra8Unorm_srgb
    public static var depthFormat: MTLPixelFormat = .depth16Unorm
    public static var clearColor: MTLClearColor = MTLClearColor(red: 0.0, green: 0.2, blue: 0.8, alpha: 1.0)
    public static var preferredFPS: Float = 60.0
}
