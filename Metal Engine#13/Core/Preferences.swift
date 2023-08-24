
import MetalKit

class Preferences {
    public static var pixelFormat: MTLPixelFormat = .bgra8Unorm_srgb
    public static var floatPixelFormat: MTLPixelFormat = .rgba16Float
    public static var signedPixelFormat: MTLPixelFormat = .rgba8Snorm
    public static var depthFormat: MTLPixelFormat = .depth32Float
    public static var clearColor: MTLClearColor = MTLClearColor(red: 0.2, green: 0.0, blue: 0.5, alpha: 1.0)
    public static var preferredFPS: Int = 60
    public static var useSkySphere: Bool = false
}
