
import MetalKit

public class Debug {
    
    private static var _pointAndLine: Debug_PointAndLine!
    public static var pointAndLine: Debug_PointAndLine { return _pointAndLine }
    
    private static var _vector: Debug_Vector!
    public static var vector: Debug_Vector { return _vector }
    
    static func initialize() {
        _pointAndLine = Debug_PointAndLine()
        _vector = Debug_Vector()
    }
}
