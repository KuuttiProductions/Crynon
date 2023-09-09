
import MetalKit

class RigidBody: Collider {
    
    //var orientation: simd_float3x3 = simd_float3x3()
    
    var material: Material = Material()
    var mass: Float = 1
    var force: simd_float3 = simd_float3(0, 0, 0)
    var linearVelocity: simd_float3 = simd_float3(0, 0, 0)
    //var angularVelocity: simd_float3 = simd_float3()
    var isActive: Bool = false
    
    var isColliding: Bool = false
    
    private var aabbPoints: [PointVertex] = [PointVertex(),
                                             PointVertex(),
                                             PointVertex(),
                                             PointVertex(),
                                             PointVertex(),
                                             PointVertex(),
                                             PointVertex(),
                                             PointVertex()]
    
    override init(_ name: String) {
        super.init(name)
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        
        if name == "physics2" {
            if InputManager.mouseLeftButton {
                self.force.y += 20
            }
            
            if InputManager.pressedKeys.contains(.leftArrow) {
                self.force.x += 5
            }
            
            if InputManager.pressedKeys.contains(.rightArrow) {
                self.force.x -= 5
            }
            
            if InputManager.pressedKeys.contains(.upArrow) {
                self.force.z -= 5
            }
            
            if InputManager.pressedKeys.contains(.downArrow) {
                self.force.z += 5
            }
        }
        
        for i in 0..<8 {
            switch i {
            case 0:
                aabbPoints[i].position = aabbMin
            case 1:
                aabbPoints[i].position = simd_float3(aabbMin.x, aabbMin.y, aabbMax.z)
            case 2:
                aabbPoints[i].position = simd_float3(aabbMin.x, aabbMax.y, aabbMin.z)
            case 3:
                aabbPoints[i].position = simd_float3(aabbMin.x, aabbMax.y, aabbMax.z)
            case 4:
                aabbPoints[i].position = aabbMax
            case 5:
                aabbPoints[i].position = simd_float3(aabbMax.x, aabbMax.y, aabbMin.z)
            case 6:
                aabbPoints[i].position = simd_float3(aabbMax.x, aabbMin.y, aabbMax.z)
            case 7:
                aabbPoints[i].position = simd_float3(aabbMax.x, aabbMin.y, aabbMin.z)
            default:
                continue
            }
            aabbPoints[i].pointSize = 50
        }
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        if isColliding {
            self.material.shaderMaterial.color = simd_float4(1, 0, 0, 1)
        } else {
            self.material.shaderMaterial.color = simd_float4(0, 1, 0, 1)
        }
        
        if material.blendMode == Renderer.currentBlendMode {
            renderCommandEncoder.pushDebugGroup("Rendering \(name!)")
            renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[material.shader])
            renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[material.shader == .Transparent ? .NoWriteAlways : .Less])
            renderCommandEncoder.setFragmentBytes(&material.shaderMaterial, length: ShaderMaterial.stride, index: 1)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureColor], index: 3)
            renderCommandEncoder.setVertexBytes(&modelConstant, length: ModelConstant.stride, index: 1)
            AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder)
        }
        
        PointAndLine.drawPoints(renderCommandEncoder: renderCommandEncoder, points: aabbPoints, color: simd_float4(1, 0.2, 0, 1))
        PointAndLine.drawLineStrip(renderCommandEncoder: renderCommandEncoder, points: aabbPoints, color: simd_float4(0, 1, 0, 1))
        super.render(renderCommandEncoder)
    }
    
    override func castShadow(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.pushDebugGroup("Casting Shadow on \(name!)")
        renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[.Shadow])
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
        renderCommandEncoder.setFragmentBytes(&material.shaderMaterial, length: ShaderMaterial.stride, index: 1)
        renderCommandEncoder.setFragmentTexture(AssetLibrary.textures["Wallpaper"], index: 3)
        renderCommandEncoder.setVertexBytes(&modelConstant, length: ModelConstant.stride, index: 1)
        renderCommandEncoder.setCullMode(.back)
        AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder)
        
        super.castShadow(renderCommandEncoder)
    }
}
