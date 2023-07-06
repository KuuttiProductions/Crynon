
import MetalKit
import GameController

//This is a test class
class Triangle: Node {
    
    var time: Float = 0.0;
    
    init() {
        super.init("Triangle")
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        InputManager.controller.extendedGamepad?.valueChangedHandler = { (gamepad, element) in
            if element == gamepad.buttonA {
                if gamepad.buttonA.isPressed {
                    self.rotate(positive: true, deltaTime: deltaTime)
                } else {
                    self.rotate(positive: false, deltaTime: deltaTime)
                }
            }
        }
        
        InputManager.keyboard?.keyboardInput?.keyChangedHandler = { (keyboard, element, code, pressed) in
            if element == keyboard.button(forKeyCode: .keyA) {
                if pressed {
                    self.rotate(positive: true, deltaTime: deltaTime)
                } else {
                    self.rotate(positive: false, deltaTime: deltaTime)
                }
            }
        }
    }
    
    func rotate(positive: Bool, deltaTime: Float) {
        self.time += deltaTime
        if positive {
            self.setRotY(self.rotation.y + deltaTime)
        } else {
            self.setRotY(self.rotation.y - deltaTime)
        }
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        MRM.setRenderPipelineState(GPLibrary.renderPipelineStates[.Basic])
        MRM.setDepthStencilState(GPLibrary.depthStencilStates[.Less]) //MRM version doesn't work right now!!!
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
        renderCommandEncoder.setVertexBytes(&self.modelConstant, length: ModelConstant.stride, index: 1)
        AssetLibrary.meshes[.Object].draw(renderCommandEncoder)
        super.render(renderCommandEncoder)
    }
}
