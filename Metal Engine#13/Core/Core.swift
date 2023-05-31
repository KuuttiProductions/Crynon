
import Metal

//Handles states of all core components
class Core {
    
    public static var commandQueue: MTLCommandQueue!
    public static var device: MTLDevice!
    
    static func initialize(device: MTLDevice!) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()
    }
}
