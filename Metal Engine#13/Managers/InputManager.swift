
import GameController

class InputManager {
    
    public static var controller = GCController()
    public static var pressed: Bool = false
    
    static func initialize() {
        createController()
    }
    
    static func test() {
        controller.extendedGamepad?.valueChangedHandler = { (gamepad, element) in
            if element == gamepad.buttonA {
                if gamepad.buttonA.isPressed {
                    pressed = true
                } else {
                    pressed = false
                }
            }
        }
    }
    
    static func createController() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect,
                                               object: nil,
                                               queue: nil) { info in
            controller = GCController.controllers()[0]
        }
    }
}
