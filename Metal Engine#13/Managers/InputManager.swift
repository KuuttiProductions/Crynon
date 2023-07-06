
import GameController

class InputManager {
    
    public static var controller = GCController()
    public static var keyboard = GCKeyboard.coalesced
    
    public static var pressed: Bool = false
    
    static func initialize() {
        createController()
        createKeyboard()
    }
    
//    static func rumble() {
//        let locals = controller.haptics?.supportedLocalities
//        controller.haptics?.createEngine(withLocality: locals)
//    }
    
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
    
    static func createKeyboard() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCKeyboardDidConnect,
                                               object: nil,
                                               queue: .main) { notification in
            keyboard = notification.object as? GCKeyboard
        }
    }
}
