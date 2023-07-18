
import MetalKit
import GameController

class FPSCamera: Camera {
    
    var moveSpeed: Float = 3
    
    init() {
        super.init("FPSCamera")
        self.fieldOfView = 80
        self.nearPlane = 0.01
        self.farPlane = 1000
    }
    
    override func tick(_ deltaTime: Float) {
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
        
        super.tick(deltaTime)
    }
}
