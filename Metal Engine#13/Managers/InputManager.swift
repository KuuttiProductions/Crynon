
import GameController

class InputManager {
    
    //Physical controllers
    public static var controller = GCController()
    public static var keyboard = GCKeyboard.coalesced
    public static var mouse = GCMouse()
    
    //Input profiles
    public static var controllerInput = { return controller.physicalInputProfile }
    public static var keyboardInput = { return keyboard?.keyboardInput! }
    public static var mouseInput = { return mouse.mouseInput }
    
    public static var pressed: Bool = false
    
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
    
    //Controller initializers
    static func initialize() {
        createController()
        createKeyboard()
        createMouse()
    }

    private static func createController() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect,
                                               object: nil,
                                               queue: nil) { info in
            controller = GCController.controllers()[0]
        }
    }
    
    private static func createKeyboard() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCKeyboardDidConnect,
                                               object: nil,
                                               queue: .main) { info in
            keyboard = info.object as? GCKeyboard
        }
    }
    
    private static func createMouse() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCMouseDidBecomeCurrent,
                                               object: nil,
                                               queue: .main) { info in
            mouse = GCMouse.current.unsafelyUnwrapped
        }
    }
}
