
import MetalKit
import GameController

class FPSCamera: Camera {
    
    init() {
        super.init("FPSCamera")
        self.fieldOfView = 80
        self.nearPlane = 0.01
        self.farPlane = 1000
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        GCMouse.current?.mouseInput?.mouseMovedHandler = { input, dx, dy in
            self.addRotZ(dx*500)
        }
    }
}
