
//This is a test class
class Triangle: Node {
    
    let mesh = Triangle_Mesh()
    
    init() {
        super.init("Triangle")
    }
    
    override func render() {
        MRM.setRenderPipelineState(GPLibrary.renderPipelineStates[.Basic])
        mesh.draw()
        super.render()
    }
}
