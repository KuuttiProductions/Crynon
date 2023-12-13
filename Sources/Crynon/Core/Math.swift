
import simd

public extension simd_float3 {
    static var AxisX: simd_float3 {
        return simd_float3(1,0,0)
    }
    static var AxisY: simd_float3 {
        return simd_float3(0,1,0)
    }
    static var AxisZ: simd_float3 {
        return simd_float3(0,0,1)
    }
}

public extension simd_float4 {
    var rgb: simd_float3 {
        return simd_float3(self.x, self.y, self.z)
    }
    var xyz: simd_float3 {
        return simd_float3(self.x, self.y, self.z)
    }
}

public extension Float {
    var deg2rad: Float {
        return self * Float.pi / 180
    }
    
    var rad2deg: Float {
        return self / Float.pi * 180
    }
}

public extension Double {
    var deg2rad: Double {
        return self * Double.pi / 180
    }
    
    var rad2deg: Double {
        return self / Double.pi * 180
    }
}

extension matrix_float4x4 {
    mutating func translate(position: simd_float3) {
        var result = matrix_float4x4()
        
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
        var result = matrix_float4x4()
        
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
        var result = matrix_float4x4()
        
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
    
    static func perspective(degreesFov: Float, aspectRatio: Float, near: Float, far: Float)-> matrix_float4x4{
        let fov = degreesFov.deg2rad
        
        let t: Float = tan(fov / 2)
        
        let x: Float = 1 / (aspectRatio * t)
        let y: Float = 1 / t
        let z: Float = -((far + near) / (far - near))
        let w: Float = -((2 * far * near) / (far - near))
        
        var result = matrix_float4x4()
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
    
    static func lookAt(position: simd_float3, target: simd_float3, up: simd_float3 = simd_float3(0,1,0))-> matrix_float4x4 {
        let n: simd_float3 = normalize(position - target)
        let u: simd_float3 = normalize(cross(up, n))
        let v: simd_float3 = cross(n, u)
        let x: Float = dot(-u, position)
        let y: Float = dot(-v, position)
        let z: Float = dot(-n, position)
        
        var result = matrix_identity_float4x4
        result.columns = (
            simd_float4(u.x, v.x, n.x, 0.0),
            simd_float4(u.y, v.y, n.y, 0.0),
            simd_float4(u.z, v.z, n.z, 0.0),
            simd_float4(  x,   y,   z, 1.0)
        )
        return result
    }
}

extension matrix_float3x3 {
    static func outerProduct(_ u: simd_float3, _ v: simd_float3)-> matrix_float3x3 {
        var result = matrix_float3x3()
        result.columns = (
            simd_float3(u.x * v.x, u.x * v.y, u.x * v.z),
            simd_float3(u.y * v.x, u.y * v.y, u.y * v.z),
            simd_float3(u.z * v.x, u.z * v.y, u.z * v.z)
        )
        return result
    }
    
    mutating func scale(_ scale: simd_float3) {
        var result = matrix_identity_float3x3
        
        let x = scale.x
        let y = scale.y
        let z = scale.z
        
        result.columns = (
            simd_float3(x, 0, 0),
            simd_float3(0, y, 0),
            simd_float3(0, 0, z)
        )
        
        self = matrix_multiply(self, result)
    }
    
    static func rotation(axis: simd_float3, angle: Float)-> matrix_float3x3 {
        var result = matrix_float3x3()
        
        let x = axis.x
        let y = axis.y
        let z = axis.z
        let o = angle
        
        let r1c1: Float = cos(o) + pow(x, 2) * (1 - cos(o))
        let r1c2: Float = x * y * (1 - cos(o)) - z * sin(o)
        let r1c3: Float = x * z * (1 - cos(o)) + y * sin(o)
        
        let r2c1: Float = y * x * (1 - cos(o)) + z * sin(o)
        let r2c2: Float = cos(o) + pow(y, 2) * (1 - cos(o))
        let r2c3: Float = y * z * (1 - cos(o)) - x * sin(o)
        
        let r3c1: Float = z * x * (1 - cos(o)) - y * sin(o)
        let r3c2: Float = z * y * (1 - cos(o)) + x * sin(o)
        let r3c3: Float = cos(o) + pow(z, 2) * (1 - cos(o))
        
        result.columns = (
            simd_float3(r1c1, r1c2, r1c3),
            simd_float3(r2c1, r2c2, r2c3),
            simd_float3(r3c1, r3c2, r3c3)
        )
        return result
    }
    
    static func rotation(direction: simd_float3, up: simd_float3 = simd_float3(0, 1, 0))-> matrix_float3x3 {
        var result = matrix_float3x3()
        
        let xAxis = normalize(cross(up, direction))
        let yAxis = normalize(cross(direction, xAxis))
        
        result.columns = (
            simd_float3(    xAxis.x,     xAxis.y,     xAxis.z),
            simd_float3(    yAxis.x,     yAxis.y,     yAxis.z),
            simd_float3(direction.x, direction.y, direction.z)
        )
    
        return result
    }
}

extension simd_float3 {
    static func rotationFromMatrix(_ matrix: simd_float3x3)-> simd_float3 {
        let trace = matrix[0][0] + matrix[1][1] + matrix[2][2]
        let cosTheta = (trace - 1.0) * 0.5
        let angle = acos(cosTheta)
        
        var axis: simd_float3
        if abs(angle) < 1e-6 {
            axis = simd_float3(1.0, 0.0, 0.0)
        } else {
            axis = simd_float3(matrix[2][1] - matrix[1][2],
                               matrix[0][2] - matrix[2][0],
                               matrix[1][0] - matrix[0][1])
            axis = normalize(axis)
        }
        
        return axis * angle
    }
}
