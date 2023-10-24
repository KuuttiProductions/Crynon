
import GameController

enum MouseButton {
    case left
    case right
    case middle
}

protocol EventInput {
    func drawKeyInput(key: GCKeyCode, down: Bool)
    
    func drawControllerInput(button: GCButtonElementName, down: Bool)
    
    func drawMouseInput(button: MouseButton, down: Bool)
}
