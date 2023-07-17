
import GameController

class InputManager {
    
    //Physical controllers
    private static var controller = GCController()
    private static var keyboard = GCKeyboard.coalesced
    private static var mouse = GCMouse()
    
    //Key states and such
    public static var pressedKeys: Set<GCKeyCode> = []
    public static var mouseLeftButton: Bool = false
    public static var mouseRightButton: Bool = false
    public static var mouseMiddleButton: Bool = false
    private static var mouseDeltaX: Float = 0.0
    private static var mouseDeltaY: Float = 0.0
    
    public static func getMouseDeltaX()-> Float {
        let deltaX = mouseDeltaX
        mouseDeltaX = 0.0
        return deltaX
    }
    
    public static func getMouseDeltaY()-> Float {
        let deltaY = mouseDeltaY
        mouseDeltaY = 0.0
        return deltaY
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
            keyboard?.keyboardInput?.keyChangedHandler = { _, _, keycode, pressed in
                if pressed {
                    pressedKeys.insert(keycode)
                } else {
                    pressedKeys.remove(keycode)
                }
            }
        }
    }
    
    private static func createMouse() {
        let observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.GCMouseDidBecomeCurrent,
                                               object: nil,
                                               queue: .main) { info in
            mouse = GCMouse.current.unsafelyUnwrapped
            mouse.mouseInput?.mouseMovedHandler = { _, deltaX, deltaY in
                mouseDeltaX = deltaX
                mouseDeltaY = deltaY
            }
            mouse.mouseInput?.leftButton.pressedChangedHandler = { _, _, pressed in
                mouseLeftButton = pressed
            }
            mouse.mouseInput?.rightButton?.pressedChangedHandler = { _, _, pressed in
                mouseRightButton = pressed
            }
            mouse.mouseInput?.middleButton?.pressedChangedHandler = { _, _, pressed in
                mouseMiddleButton = pressed
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCMouseDidStopBeingCurrent,
                                               object: nil,
                                               queue: .main) { info in
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
