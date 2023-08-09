
import MetalKit

class CubeObject: GameObject {
    
    init() {
        super.init("CubeObject")
        self.material.shaderMaterial.roughness = 0.5
        self.material.shaderMaterial.color = simd_float4(1.0, 1.0, 1.0, 1.0)
        self.mesh = .Cube
        self.textureColor = "Wallpaper"
    }
    
}
