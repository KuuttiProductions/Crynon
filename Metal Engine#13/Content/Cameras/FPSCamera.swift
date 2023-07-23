
import MetalKit

class FPSCamera: Camera {
    
    var moveSpeed: Float = 3
    var time: Float = 0.0
    
    init() {
        super.init("FPSCamera")
        self.fieldOfView = 80
        self.nearPlane = 0.03
        self.farPlane = 1000
    }
    
    override func tick(_ deltaTime: Float) {
        self.time += deltaTime
        
        //Rotation with mouse Input
        self.addRotY(InputManager.getMouseDeltaX() * deltaTime * 0.2)
        self.addRotX(-InputManager.getMouseDeltaY() * deltaTime * 0.2)
        
        //Moving with keyboard input
        if InputManager.pressedKeys.contains(.keyW) {
            self.addPos(forwardVector * deltaTime * moveSpeed)
        }
        if InputManager.pressedKeys.contains(.keyS) {
            self.addPos(-forwardVector * deltaTime * moveSpeed)
        }
        if InputManager.pressedKeys.contains(.keyA) {
            self.addPos(-rightVector * deltaTime * moveSpeed)
        }
        if InputManager.pressedKeys.contains(.keyD) {
            self.addPos(rightVector * deltaTime * moveSpeed)
        }
        if InputManager.pressedKeys.contains(.spacebar) {
            self.addPosY(deltaTime * moveSpeed)
        }
        if InputManager.pressedKeys.contains(.leftShift) {
            self.addPosY(-deltaTime * moveSpeed)
        }
        
        //Changing FOV with scroll
        self.fieldOfView += InputManager.getScrollDeltaY() * deltaTime * moveSpeed
        
        //Movement and rotation with Controller
        self.addRotY(InputManager.controllerRX * deltaTime * moveSpeed)
        self.addRotX(-InputManager.controllerRY * deltaTime * moveSpeed)
        self.addPos(forwardVector * deltaTime * InputManager.controllerLY * moveSpeed)
        self.addPos(rightVector * deltaTime * InputManager.controllerLX * moveSpeed)
        if InputManager.controllerA { self.addPosY(deltaTime * moveSpeed) }
        if InputManager.controllerB { self.addPosY(-deltaTime * moveSpeed); InputManager.playTransientHaptic(0.5) }
        
        //Changing FOV with triggers and haptic feedback
        self.fieldOfView += InputManager.controllerTriggerL * deltaTime * 50
        self.fieldOfView -= InputManager.controllerTriggerR * deltaTime * 50
        if InputManager.controllerTriggerL > 0.0 {
            InputManager.playTransientHaptic(InputManager.controllerTriggerL/7, .leftTrigger)
        }
        if InputManager.controllerTriggerR > 0.0 {
            InputManager.playTransientHaptic(InputManager.controllerTriggerR/7, .rightTrigger)
        }
        
        super.tick(deltaTime)
    }
}
