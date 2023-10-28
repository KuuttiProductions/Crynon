
import MetalKit
import SwiftUI

class Preferences {
    public static var pixelFormat: MTLPixelFormat = .bgra8Unorm_srgb
    public static var floatPixelFormat: MTLPixelFormat = .rgba16Float
    public static var signedPixelFormat: MTLPixelFormat = .rgba8Snorm
    public static var depthFormat: MTLPixelFormat = .depth32Float
    public static var clearColor: MTLClearColor = MTLClearColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
    public static var preferredFPS: Int = 120
    public static var useSkySphere: Bool = false
    public static var fogAmount: Float = 0.0
}
