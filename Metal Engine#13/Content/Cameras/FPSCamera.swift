
import MetalKit
import GameController

class FPSCamera: Camera {
    
    var moveSpeed: Float = 0.2
    
    init() {
        super.init("FPSCamera")
        self.fieldOfView = 80
        self.nearPlane = 0.01
        self.farPlane = 1000
    }
    
    override func tick(_ deltaTime: Float) {
        //Rotation with mouse Input
        self.addRotY(InputManager.getMouseDeltaX() * deltaTime * 0.1)
        self.addRotX(-InputManager.getMouseDeltaY() * deltaTime * 0.1)
        
        //Moving with keyboard input
        if InputManager.pressedKeys.contains(.keyW) {
            self.addPos(forwardVector * moveSpeed)
        }
        if InputManager.pressedKeys.contains(.keyS) {
            self.addPos(-forwardVector * moveSpeed)
        }
        if InputManager.pressedKeys.contains(.keyA) {
            self.addPos(rightVector * moveSpeed)
        }
        if InputManager.pressedKeys.contains(.keyD) {
            self.addPos(-rightVector * moveSpeed)
        }
        
        super.tick(deltaTime)
    }
}
