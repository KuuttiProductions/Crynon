//
//  test.swift
//  Metal Engine#13
//
//  Created by Kuutti Taavitsainen on 1.6.2023.
//

import MetalKit

//GET RID OF THIS ASAP
class test {
    
    init() {
        makeBuffer()
    }
    
    let vertices: [Vertex] = [
        Vertex(position: simd_float3(-1, -1, 0), color: simd_float4(1, 0, 0, 1)),
        Vertex(position: simd_float3( 0,  1, 0), color: simd_float4(0, 1, 0, 1)),
        Vertex(position: simd_float3( 1, -1, 0), color: simd_float4(0, 0, 1, 1))
    ]
    var vertexBuffer: MTLBuffer!
    var pipeline: MTLRenderPipelineState!
    
    func makeBuffer() {
        vertexBuffer = Core.device.makeBuffer(bytes: vertices, length: Vertex.stride * vertices.count)!
    }
}
