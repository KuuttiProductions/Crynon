
import MetalKit

public class Debug {
    
    private static var _pointAndLine: Debug_PointAndLine!
    public static var pointAndLine: Debug_PointAndLine { return _pointAndLine }
    
    private static var _vector: Debug_Vector!
    public static var vector: Debug_Vector { return _vector }
    
    private static var _viewStateCenter: DebugViewState!
    public static var viewStateCenter: DebugViewState { return _viewStateCenter }
    
    static func initialize() {
        _pointAndLine = Debug_PointAndLine()
        _vector = Debug_Vector()
        _viewStateCenter = DebugViewState()
    }
    
    internal static func render(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        Debug._pointAndLine.render(renderCommandEncoder: renderCommandEncoder)
    }
}
