
import GameController
import CoreHaptics

class InputManager {
    
    //Physical controllers
    public static var controller = GCController()
    public static var keyboard = GCKeyboard.coalesced
    public static var mouse = GCMouse()
    
    //Key states and such
    public static var controllerLX: Float = 0.0
    public static var controllerLY: Float = 0.0
    public static var controllerRX: Float = 0.0
    public static var controllerRY: Float = 0.0
    public static var controllerTriggerL: Float = 0.0
    public static var controllerTriggerR: Float = 0.0
    public static var controllerA: Bool = false
    public static var controllerB: Bool = false
    public static var controllerX: Bool = false
    public static var controllerY: Bool = false
    public static var controllerThumbstickL: Bool = false
    public static var controllerThumbstickR: Bool = false
    public static var pressedKeys: Set<GCKeyCode> = []
    public static var mouseLeftButton: Bool = false
    public static var mouseRightButton: Bool = false
    public static var mouseMiddleButton: Bool = false
    private static var mouseDeltaX: Float = 0.0
    private static var mouseDeltaY: Float = 0.0
    private static var scrollDeltaX: Float = 0.0
    private static var scrollDeltaY: Float = 0.0
    public static var hapticEngineHandles: CHHapticEngine!
    public static var hapticEngineLeftTrigger: CHHapticEngine!
    public static var hapticEngineRightTrigger: CHHapticEngine!
    
    public static  func playTransientHaptic(_ intensity: Float, _ locality: GCHapticsLocality = .handles) {
        if getHapticEngine(locality) != nil {
            do {
                let hapticPlayer = try patternPlayerForHaptics(intensity, getHapticEngine(locality)!)
                try hapticPlayer?.start(atTime: CHHapticTimeImmediate)
            } catch let error {
                print ("Haptic playback error: \(error)")
            }
        }
    }
    
    static func getHapticEngine(_ locality: GCHapticsLocality)-> CHHapticEngine? {
        switch locality {
        case .handles:
            return hapticEngineHandles
        case .leftTrigger:
            return hapticEngineLeftTrigger
        case .rightTrigger:
            return hapticEngineRightTrigger
        default:
            return hapticEngineHandles
        }
    }
    
    public static func patternPlayerForHaptics(_ intensity: Float, _ engine: CHHapticEngine) throws -> CHHapticPatternPlayer? {
        let transientEvent = CHHapticEvent(eventType: .hapticTransient, parameters: [
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.0),
            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        ], relativeTime: 0)
        let pattern = try CHHapticPattern(events: [transientEvent], parameters: [])
        return try engine.makePlayer(with: pattern)
    }
    
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
    
    public static func getScrollDeltaX()-> Float {
        let deltaX = scrollDeltaX
        scrollDeltaX = 0.0
        return deltaX
    }
    
    public static func getScrollDeltaY()-> Float {
        let deltaY = scrollDeltaY
        scrollDeltaX = 0.0
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
            controller.extendedGamepad?.valueChangedHandler = { profile, element in
                if element == profile.leftThumbstick {
                    controllerLX = profile.leftThumbstick.xAxis.value
                }
                if element == profile.leftThumbstick {
                    controllerLY = profile.leftThumbstick.yAxis.value
                }
                if element == profile.rightThumbstick {
                    controllerRX = profile.rightThumbstick.xAxis.value
                }
                if element == profile.rightThumbstick {
                    controllerRY = profile.rightThumbstick.yAxis.value
                }
                if element == profile.leftTrigger {
                    controllerTriggerL = profile.leftTrigger.value
                }
                if element == profile.rightTrigger {
                    controllerTriggerR = profile.rightTrigger.value
                }
                if element == profile.buttonA {
                    controllerA = profile.buttonA.isPressed
                }
                if element == profile.buttonB {
                    controllerB = profile.buttonB.isPressed
                }
                if element == profile.buttonX {
                    controllerX = profile.buttonX.isPressed
                }
                if element == profile.buttonY {
                    controllerY = profile.buttonY.isPressed
                }
            }
            hapticEngineHandles = controller.haptics?.createEngine(withLocality: .handles)
            hapticEngineLeftTrigger = controller.haptics?.createEngine(withLocality: .leftTrigger)
            hapticEngineRightTrigger = controller.haptics?.createEngine(withLocality: .rightTrigger)
            do {
                try hapticEngineHandles?.start()
                try hapticEngineLeftTrigger?.start()
                try hapticEngineRightTrigger?.start()
            } catch let error {
                print("Error: \(error)")
            }
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
                self.mouseDeltaX = deltaX
                self.mouseDeltaY = deltaY
            }
            mouse.mouseInput?.leftButton.pressedChangedHandler = { _, _, pressed in
                self.mouseLeftButton = pressed
            }
            mouse.mouseInput?.rightButton?.pressedChangedHandler = { _, _, pressed in
                self.mouseRightButton = pressed
            }
            mouse.mouseInput?.middleButton?.pressedChangedHandler = { _, _, pressed in
                self.mouseMiddleButton = pressed
            }
            mouse.mouseInput?.scroll.xAxis.valueChangedHandler = { _, value in
                self.scrollDeltaX = value
            }
            mouse.mouseInput?.scroll.yAxis.valueChangedHandler = { _, value in
                self.scrollDeltaY = value
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCMouseDidStopBeingCurrent,
                                               object: nil,
                                               queue: .main) { info in
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
