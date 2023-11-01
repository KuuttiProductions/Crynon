
import MetalKit

class Debug_PointAndLine {
    func drawPoints(renderCommandEncoder: MTLRenderCommandEncoder, positions: [simd_float3], color: simd_float4 = simd_float4(1,1,1,1), pointSize: Float = 10) {
        var points: [PointVertex] = []
        var color: simd_float4 = color
        for position in positions {
            points.append(PointVertex(position: position, pointSize: pointSize))
        }
        renderCommandEncoder.pushDebugGroup("Rendering \(points.count) points")
        setDefaults(renderCommandEncoder)
        renderCommandEncoder.setVertexBytes(points, length: PointVertex.stride(count: points.count), index: 0)
        renderCommandEncoder.setFragmentBytes(&color, length: simd_float4.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: points.count)
        renderCommandEncoder.popDebugGroup()
    }
    
    func drawPoints(renderCommandEncoder: MTLRenderCommandEncoder, points: [PointVertex], color: simd_float4 = simd_float4(1,1,1,1)) {
        var points = points
        var color: simd_float4 = color
        renderCommandEncoder.pushDebugGroup("Rendering \(points.count) points")
        setDefaults(renderCommandEncoder)
        renderCommandEncoder.setVertexBytes(&points, length: PointVertex.stride(count: points.count), index: 0)
        renderCommandEncoder.setFragmentBytes(&color, length: simd_float4.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: points.count)
        renderCommandEncoder.popDebugGroup()
    }
    
    func drawLineStrip(renderCommandEncoder: MTLRenderCommandEncoder, positions: [simd_float3], color: simd_float4 = simd_float4(1,1,1,1)) {
        var points: [PointVertex] = []
        for position in positions {
            points.append(PointVertex(position: position))
        }
        var color: simd_float4 = color
        renderCommandEncoder.pushDebugGroup("Rendering lines with \(points.count) points")
        setDefaults(renderCommandEncoder)
        renderCommandEncoder.setVertexBytes(&points, length: PointVertex.stride(count: points.count), index: 0)
        renderCommandEncoder.setFragmentBytes(&color, length: simd_float4.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: points.count)
        renderCommandEncoder.popDebugGroup()
    }
    
    func drawLineStrip(renderCommandEncoder: MTLRenderCommandEncoder, points: [PointVertex], color: simd_float4 = simd_float4(1,1,1,1)) {
        var points = points
        var color: simd_float4 = color
        renderCommandEncoder.pushDebugGroup("Rendering lines with \(points.count) points")
        setDefaults(renderCommandEncoder)
        renderCommandEncoder.setVertexBytes(&points, length: PointVertex.stride(count: points.count), index: 0)
        renderCommandEncoder.setFragmentBytes(&color, length: simd_float4.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: points.count)
        renderCommandEncoder.popDebugGroup()
    }
    
    func drawLine(renderCommandEncoder: MTLRenderCommandEncoder, point1: PointVertex, point2: PointVertex, color: simd_float4 = simd_float4(1,1,1,1)) {
        var points: [PointVertex] = [point1, point2]
        var color: simd_float4 = color
        renderCommandEncoder.pushDebugGroup("Rendering lines with \(points.count) points")
        setDefaults(renderCommandEncoder)
        renderCommandEncoder.setVertexBytes(&points, length: PointVertex.stride*2, index: 0)
        renderCommandEncoder.setFragmentBytes(&color, length: simd_float4.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: points.count)
        renderCommandEncoder.popDebugGroup()
    }
    
    func drawLine(renderCommandEncoder: MTLRenderCommandEncoder, position1: simd_float3, position2: simd_float3, color: simd_float4 = simd_float4(1,1,1,1)) {
        var points: [PointVertex] = [PointVertex(position: position1), PointVertex(position: position2)]
        var color: simd_float4 = color
        renderCommandEncoder.pushDebugGroup("Rendering lines with \(points.count) points")
        setDefaults(renderCommandEncoder)
        renderCommandEncoder.setVertexBytes(&points, length: PointVertex.stride*2, index: 0)
        renderCommandEncoder.setFragmentBytes(&color, length: simd_float4.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: points.count)
        renderCommandEncoder.popDebugGroup()
    }
    
    func setDefaults(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[.PointAndLine])
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
    }
}
