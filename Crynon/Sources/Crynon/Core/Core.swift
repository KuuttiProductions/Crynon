
import Metal

//Handles states of all core components
open class Core: ObservableObject {
    
    private static var _commandQueue: MTLCommandQueue!
    private static var _defaultLibrary: MTLLibrary!
    private static var _device: MTLDevice!
    
    public static var commandQueue: MTLCommandQueue { _commandQueue }
    public static var defaultLibrary: MTLLibrary { _defaultLibrary }
    public static var device: MTLDevice { _device }
    
    public init() {
        Core._device = MTLCreateSystemDefaultDevice()
        Core._commandQueue = Core.device.makeCommandQueue()
        Core._defaultLibrary = try! Core.device.makeDefaultLibrary(bundle: .module)
        
        GPLibrary.initialize()
        AssetLibrary.initialize()
        
        InputManager.initialize()
        
        SceneManager.initialize()
        
        Debug.initialize()
    }
}
