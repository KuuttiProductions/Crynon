
import MetalKit

class Preferences {
    public static var pixelFormat: MTLPixelFormat = .bgra8Unorm_srgb
    public static var signedPixelFormat: MTLPixelFormat = .rgba8Snorm
    public static var depthFormat: MTLPixelFormat = .depth32Float_stencil8
    public static var clearColor: MTLClearColor = MTLClearColor(red: 0.0, green: 0.2, blue: 0.9, alpha: 1.0)
    public static var preferredFPS: Int = 60
    public static var useSkySphere: Bool = false
}
