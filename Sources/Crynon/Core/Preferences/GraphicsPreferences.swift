
import MetalKit

public class GraphicsPreferences {
    public var useSkySphere: Bool = false
    public var clearColor: MTLClearColor = MTLClearColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
    public var shadowMapResolution: Int = 1024
    public var useSSAO: Bool = false
    public var useBloom: Bool = false
    public var bloomThreshold: Float = 0.8
    public var bloomIntensity: Float = 1.0
    public var outputHDR: Bool = false
}
