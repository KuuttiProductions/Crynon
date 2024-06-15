
import MetalKit

public class Debug_PointAndLine {
    
    var points: [PointVertex] = []
    var lines: [PointVertex] = []
    
    public func addPointsToDraw(points: [PointVertex]) {
        self.points.append(contentsOf: points)
    }
    
    public func addLinesToDraw(lines: [PointVertex]) {
        self.lines.append(contentsOf: lines)
    }
    
    internal func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        var color = simd_float4(1, 0, 0, 1)
        if !points.isEmpty {
            renderCommandEncoder.pushDebugGroup("Rendering \(points.count) points")
            setDefaults(renderCommandEncoder)
            renderCommandEncoder.setVertexBytes(points, length: PointVertex.stride(count: points.count), index: 0)
            renderCommandEncoder.setFragmentBytes(&color, length: simd_float4.stride, index: 1)
            renderCommandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: points.count)
            renderCommandEncoder.popDebugGroup()
            points.removeAll()
        }
        
        if lines.isEmpty { return }
        renderCommandEncoder.pushDebugGroup("Rendering \(lines.count / 2) lines")
        setDefaults(renderCommandEncoder)
        renderCommandEncoder.setVertexBytes(lines, length: PointVertex.stride(count: lines.count), index: 0)
        renderCommandEncoder.setFragmentBytes(&color, length: simd_float4.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: lines.count)
        renderCommandEncoder.popDebugGroup()
        lines.removeAll()
    }
    
    public func drawPoints(renderCommandEncoder: MTLRenderCommandEncoder, positions: [simd_float3], color: simd_float4 = simd_float4(1,1,1,1), pointSize: Float = 10) {
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
    
    public func drawPoints(renderCommandEncoder: MTLRenderCommandEncoder, points: [PointVertex], color: simd_float4 = simd_float4(1,1,1,1)) {
        var points = points
        var color: simd_float4 = color
        renderCommandEncoder.pushDebugGroup("Rendering \(points.count) points")
        setDefaults(renderCommandEncoder)
        renderCommandEncoder.setVertexBytes(&points, length: PointVertex.stride(count: points.count), index: 0)
        renderCommandEncoder.setFragmentBytes(&color, length: simd_float4.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: points.count)
        renderCommandEncoder.popDebugGroup()
    }
    
    public func drawLineStrip(renderCommandEncoder: MTLRenderCommandEncoder, positions: [simd_float3], color: simd_float4 = simd_float4(1,1,1,1)) {
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
    
    public func drawLineStrip(renderCommandEncoder: MTLRenderCommandEncoder, points: [PointVertex], color: simd_float4 = simd_float4(1,1,1,1)) {
        var points = points
        var color: simd_float4 = color
        renderCommandEncoder.pushDebugGroup("Rendering lines with \(points.count) points")
        setDefaults(renderCommandEncoder)
        renderCommandEncoder.setVertexBytes(&points, length: PointVertex.stride(count: points.count), index: 0)
        renderCommandEncoder.setFragmentBytes(&color, length: simd_float4.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: points.count)
        renderCommandEncoder.popDebugGroup()
    }
    
    public func drawLine(renderCommandEncoder: MTLRenderCommandEncoder, point1: PointVertex, point2: PointVertex, color: simd_float4 = simd_float4(1,1,1,1)) {
        var points: [PointVertex] = [point1, point2]
        var color: simd_float4 = color
        renderCommandEncoder.pushDebugGroup("Rendering lines with \(points.count) points")
        setDefaults(renderCommandEncoder)
        renderCommandEncoder.setVertexBytes(&points, length: PointVertex.stride*2, index: 0)
        renderCommandEncoder.setFragmentBytes(&color, length: simd_float4.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: points.count)
        renderCommandEncoder.popDebugGroup()
    }
    
    public func drawLine(renderCommandEncoder: MTLRenderCommandEncoder, position1: simd_float3, position2: simd_float3, color: simd_float4 = simd_float4(1,1,1,1)) {
        var points: [PointVertex] = [PointVertex(position: position1), PointVertex(position: position2)]
        var color: simd_float4 = color
        renderCommandEncoder.pushDebugGroup("Rendering lines with \(points.count) points")
        setDefaults(renderCommandEncoder)
        renderCommandEncoder.setVertexBytes(&points, length: PointVertex.stride*2, index: 0)
        renderCommandEncoder.setFragmentBytes(&color, length: simd_float4.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: points.count)
        renderCommandEncoder.popDebugGroup()
    }
    
    private func setDefaults(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[.PointAndLine])
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
    }
}
