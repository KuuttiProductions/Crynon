
import MetalKit

class Debug_Vector {
    func drawVector(renderCommandEncoder: MTLRenderCommandEncoder,
                    vector: simd_float3,
                    origin: simd_float3 = simd_float3(0, 0, 0),
                    color: simd_float4 = simd_float4(1, 1, 1, 1),
                    emissive: Bool = true) {
        var material = Material()
        var modelConstant = ModelConstant()
        
        material.shaderMaterial.color = color
        material.shaderMaterial.emission = emissive ? 1.0 : 0.0
        
        let scale = simd_float3(1, abs(length(vector)), 1)
        var rotation = normalize(vector)
        
        let reference = simd_float3(0,0,0)
        let rotationAxis = cross(reference, vector)
        let dotP = dot(reference, vector)
        let rotationAngle = acos(dotP)
        
        rotation = rotationAxis * rotationAngle
        
        var modelMatrix: matrix_float4x4 {
            var modelMatrix = matrix_identity_float4x4
            modelMatrix.translate(position: origin)
            modelMatrix.rotate(direction: rotation.x, axis: .AxisX)
            modelMatrix.rotate(direction: rotation.y, axis: .AxisY)
            modelMatrix.rotate(direction: rotation.z, axis: .AxisZ)
            modelMatrix.scale(scale)
            return modelMatrix
        }
        modelConstant.modelMatrix = modelMatrix
        
        renderCommandEncoder.pushDebugGroup("Drawing a vector")
        renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[.Geometry])
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
        renderCommandEncoder.setVertexBytes(&modelConstant, length: ModelConstant.stride, index: 1)
        renderCommandEncoder.setFragmentBytes(&material.shaderMaterial, length: ShaderMaterial.stride, index: 1)
        AssetLibrary.meshes[.Vector].draw(renderCommandEncoder)
        renderCommandEncoder.popDebugGroup()
    }
    
    func drawVector(renderCommandEncoder: MTLRenderCommandEncoder,
                    angle: simd_float3,
                    length: Float,
                    origin: simd_float3 = simd_float3(0, 0, 0),
                    color: simd_float4 = simd_float4(1, 1, 1, 1),
                    emissive: Bool = true) {
        var material = Material()
        var modelConstant = ModelConstant()
        
        material.shaderMaterial.color = color
        material.shaderMaterial.emission = emissive ? 1.0 : 0.0
        
        let scale = simd_float3(1, length, 1)
        
        var modelMatrix: matrix_float4x4 {
            var modelMatrix = matrix_identity_float4x4
            modelMatrix.translate(position: origin)
            modelMatrix.rotate(direction: angle.x, axis: .AxisX)
            modelMatrix.rotate(direction: angle.y, axis: .AxisY)
            modelMatrix.rotate(direction: angle.z, axis: .AxisZ)
            modelMatrix.scale(scale)
            return modelMatrix
        }
        modelConstant.modelMatrix = modelMatrix
        
        renderCommandEncoder.pushDebugGroup("Drawing a vector")
        renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[.Geometry])
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
        renderCommandEncoder.setVertexBytes(&modelConstant, length: ModelConstant.stride, index: 1)
        renderCommandEncoder.setFragmentBytes(&material.shaderMaterial, length: ShaderMaterial.stride, index: 1)
        AssetLibrary.meshes[.Vector].draw(renderCommandEncoder)
        renderCommandEncoder.popDebugGroup()
    }
}
