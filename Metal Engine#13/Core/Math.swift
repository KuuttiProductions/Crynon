
import simd

extension simd_float3 {
    public static var AxisX: simd_float3 {
        return simd_float3(1,0,0)
    }
    public static var AxisY: simd_float3 {
        return simd_float3(0,1,0)
    }
    public static var AxisZ: simd_float3 {
        return simd_float3(0,0,1)
    }
}

extension Float {
    var deg2rad: Float {
        return self * Float.pi / 180
    }
    
    var rad2deg: Float {
        return self / Float.pi * 180
    }
}

extension matrix_float4x4 {
    
    mutating func translate(position: simd_float3) {
        var result = matrix_identity_float4x4
        
        let x = position.x
        let y = position.y
        let z = position.z
        
        result.columns = (
            simd_float4(1,0,0,0),
            simd_float4(0,1,0,0),
            simd_float4(0,0,1,0),
            simd_float4(x,y,z,1)
        )
        self = matrix_multiply(self, result)
    }
    
    mutating func scale(_ scale: simd_float3) {
        var result = matrix_identity_float4x4
        
        let x = scale.x
        let y = scale.y
        let z = scale.z
        
        result.columns = (
            simd_float4(x, 0, 0, 0),
            simd_float4(0, y, 0, 0),
            simd_float4(0, 0, z, 0),
            simd_float4(0, 0, 0, 1)
        )
        
        self = matrix_multiply(self, result)
    }
    
    mutating func rotate(direction: Float, axis: simd_float3) {
        var result = matrix_identity_float4x4
        
        let x: Float = axis.x
        let y: Float = axis.y
        let z: Float = axis.z
        
        let c: Float = cos(direction)
        let s: Float = sin(direction)
        
        let mc: Float = (1 - c)
        
        let r1c1: Float = x * x * mc + c
        let r1c2: Float = x * y * mc + z * s
        let r1c3: Float = x * z * mc - y * s
        let r1c4: Float = 0.0
        
        let r2c1: Float = y * x * mc - z * s
        let r2c2: Float = y * y * mc + c
        let r2c3: Float = y * z * mc + x * s
        let r2c4: Float = 0.0
        
        let r3c1: Float = z * x * mc + y * s
        let r3c2: Float = z * y * mc - x * s
        let r3c3: Float = z * z * mc + c
        let r3c4: Float = 0.0
        
        let r4c1: Float = 0.0
        let r4c2: Float = 0.0
        let r4c3: Float = 0.0
        let r4c4: Float = 1.0
        
        result.columns = (
            simd_float4(r1c1, r1c2, r1c3, r1c4),
            simd_float4(r2c1, r2c2, r2c3, r2c4),
            simd_float4(r3c1, r3c2, r3c3, r3c4),
            simd_float4(r4c1, r4c2, r4c3, r4c4)
        )
        
        self = matrix_multiply(self, result)
    }
    
    static func perspective(degreesFov: Float, aspectRatio: Float, near: Float, far: Float)->matrix_float4x4{
        let fov = degreesFov.deg2rad
        
        let t: Float = tan(fov / 2)
        
        let x: Float = 1 / (aspectRatio * t)
        let y: Float = 1 / t
        let z: Float = -((far + near) / (far - near))
        let w: Float = -((2 * far * near) / (far - near))
        
        var result = matrix_identity_float4x4
        result.columns = (
            simd_float4(x, 0, 0,  0),
            simd_float4(0, y, 0,  0),
            simd_float4(0, 0, z, -1),
            simd_float4(0, 0, w,  0)
        )
        return result
    }
    
    static func orthographic(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float)-> matrix_float4x4 {
        let x = 2 / (right-left)
        let y = 2 / (top-bottom)
        let z = -2 / (far-near)
        let u = -((left+right) / (right-left))
        let w = -((top+bottom) / (top-bottom))
        let q = -((far+near) / (far-near))
        
        var result = matrix_identity_float4x4
        result.columns = (
            simd_float4(x, 0, 0, 0),
            simd_float4(0, y, 0, 0),
            simd_float4(0, 0, z, 0),
            simd_float4(u, w, q, 1)
        )
        
        
        
        return result
    }
}
