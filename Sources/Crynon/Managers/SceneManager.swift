
import MetalKit
import SwiftUI

//Takes care of updating the current Scene
//and switching of scenes.
open class SceneManager {
    
    static private var _currentScene: Scene!
    static public var inScene = { return _currentScene == nil ? false : true }
    
    static func initialize() {
 
    }
    
    public static func changeScene(_ newScene: Scene) {
        _currentScene = newScene
    }
    
    static func tick(_ deltaTime: Float) {
        _currentScene.tick(deltaTime)
    }
    
    static func physicsTick(_ deltaTime: Float) {
        _currentScene.physicsTick(deltaTime)
    }
    
    static func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        _currentScene.render(renderCommandEncoder)
    }
    
    static func lightingPass(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        _currentScene.lightingPass(renderCommandEncoder)
    }
    
    static func castShadow(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        _currentScene.castShadow(renderCommandEncoder)
    }
}
