
import MetalKit

class MetalPreferences {
    var outputPixelFormat: MTLPixelFormat = .bgra8Unorm
    var pixelFormat: MTLPixelFormat = .rgba16Float
    var floatPixelFormat: MTLPixelFormat = .rgba16Float
    var signedPixelFormat: MTLPixelFormat = .rgba8Snorm
    var depthFormat: MTLPixelFormat = .depth32Float
}
