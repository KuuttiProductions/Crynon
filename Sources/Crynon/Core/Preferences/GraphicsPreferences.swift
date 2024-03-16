
import MetalKit

public class GraphicsPreferences {
    public var useSkySphere: Bool = false
    public var fogAmount: Float = 0.0
    public var clearColor: MTLClearColor = MTLClearColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)
    public var shadowMapResolution: Int = 1024
    public var useSSAO: Bool = false
    public var useBloom: Bool = false
}
