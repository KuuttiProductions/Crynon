
import SwiftUI
import MetalKit

struct ContentView: View {
    var body: some View {
        VStack {
            Text("This is a SwiftUI driven text")
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .padding(10)
            GameView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
