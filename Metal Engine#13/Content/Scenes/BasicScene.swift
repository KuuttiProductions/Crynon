
class BasicScene: Scene {
    
    let triangle = Triangle()
    
    init() {
        super.init("BasicScene")
        addChild(triangle)
    }
}
