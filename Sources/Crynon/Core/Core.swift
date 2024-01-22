
import Metal

//Handles states of all core components
open class Core: ObservableObject {
    
    private static var _commandQueue: MTLCommandQueue!
    private static var _defaultLibrary: MTLLibrary!
    private static var _device: MTLDevice!
    
    public static var commandQueue: MTLCommandQueue { _commandQueue }
    public static var defaultLibrary: MTLLibrary { _defaultLibrary }
    public static var device: MTLDevice { _device }
    public static var paused: Bool = false
    
    public init(development: Bool = false) {
        Core._device = MTLCreateSystemDefaultDevice()
        Core._commandQueue = Core.device.makeCommandQueue()
        
        if development {
            compileShaderSources()
        } else {
            do {
                Core._defaultLibrary = try Core.device.makeDefaultLibrary(bundle: .module)
                Core._defaultLibrary.label = "Runtime Library"
            } catch let error as NSError { print(error) }
        }
        
        Preferences.initialize()
        
        GPLibrary.initialize()
        AssetLibrary.initialize()
        
        InputManager.initialize()
        
        SceneManager.initialize()
        
        Debug.initialize()
        
    }
    
    func compileShaderSources() {
        let libraryURL = Bundle.module.url(forResource: "ShaderLib", withExtension: "metallib", subdirectory: "CompiledShaders")
    
        guard let libraryURL else {
            print("Error locating precompiled shader library")
            return
        }
        
        let preLibrary: MTLLibrary!
        do {
            preLibrary = try Core.device.makeLibrary(URL: libraryURL)
            preLibrary.label = "Precompiled Library"
        } catch {
            print(error)
            return
        }

        Core._defaultLibrary = preLibrary
        print("Using precompiled library")
    }
}
