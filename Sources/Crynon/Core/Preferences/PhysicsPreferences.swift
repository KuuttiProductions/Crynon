
import simd

public class PhysicsPreferences {
    public var gravity: simd_float3 = simd_float3(0, -9.81, 0)
    
    public var accumulateImpulses: Bool = false
    public var positionCorrection: Bool = true
    public var warmStarting: Bool = true
    
    public var iterations: Int = 8
}
