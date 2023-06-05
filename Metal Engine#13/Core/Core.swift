
import Metal

//Handles states of all core components
class Core {
    
    public static var commandQueue: MTLCommandQueue!
    public static var defaultLibrary: MTLLibrary!
    public static var device: MTLDevice!
    
    static func initialize(device: MTLDevice!) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        self.defaultLibrary = device.makeDefaultLibrary()
        
        GPLibrary.initialize()
        AssetLibrary.initialize()
        
        SceneManager.initialize()
    }
}
