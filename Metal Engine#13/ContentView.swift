
import SwiftUI
import MetalKit

struct ContentView: View {
    var body: some View {
        VStack {
            Text("This is a SwiftUI driven text")
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontDesign(.rounded)
            GameView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct GameView: NSViewRepresentable {
    func updateNSView(_ nsView: MTKView, context: Context) {
        print("Hi")
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        
        mtkView.device = MTLCreateSystemDefaultDevice()
        
        return mtkView
    }
}
