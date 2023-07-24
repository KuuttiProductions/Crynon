
import MetalKit
import SwiftUI

enum SceneType {
    case Basic
}

//Takes care of updating the current Scene
//and switching of scenes.
class SceneManager {
    
    static private var _currentScene: Scene!
    
    static func initialize() {
        changeScene(.Basic)
    }
    
    static func changeScene(_ newScene: SceneType) {
        switch newScene {
        case .Basic:
            _currentScene = BasicScene()
        }
    }
    
    static func tick(_ deltaTime: Float) {
        _currentScene.tick(deltaTime)
    }
    
    static func physicsTick() {
        _currentScene.physicsTick()
    }
    
    static func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        _currentScene.render(renderCommandEncoder)
    }
    
    static func castShadow(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        _currentScene.castShadow(renderCommandEncoder)
    }
}
