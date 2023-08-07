
import MetalKit

class CubeObject: GameObject {
    
    init() {
        super.init("CubeObject")
        self.material.roughness = 1.0;
        self.material.color = simd_float4(1.0, 1.0, 1.0, 1.0)
        self.mesh = .Cube
        self.textureColor = "Wallpaper"
    }
    
}
