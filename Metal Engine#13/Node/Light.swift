
import MetalKit

class Light: Node {
    
    var lightData: LightData = LightData()

    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        lightData.position = self.position
    }
}
