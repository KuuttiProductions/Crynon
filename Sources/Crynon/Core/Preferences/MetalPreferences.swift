
import MetalKit

class MetalPreferences {
    var pixelFormat: MTLPixelFormat = .bgra8Unorm_srgb
    var floatPixelFormat: MTLPixelFormat = .rgba16Float
    var signedPixelFormat: MTLPixelFormat = .rgba8Snorm
    var depthFormat: MTLPixelFormat = .depth32Float
}
