
enum SceneType {
    case Basic
}

//Takes care of updating the current Scene
//and switching of scenes.
class SceneManager {
    
    private static var _currentScene: Scene!
    
    public static func initialize() {
        changeScene(.Basic)
    }
    
    static func changeScene(_ newScene: SceneType) {
        switch newScene {
        case .Basic:
            _currentScene = BasicScene()
        default:
            _currentScene = BasicScene()
        }
    }
    
    static func tick() {
        _currentScene.tick()
    }
    
    static func physicsTick() {
        _currentScene.physicsTick()
    }
    
    static func render() {
        _currentScene.render()
    }
}
