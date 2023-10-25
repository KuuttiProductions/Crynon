
import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var core: Core
    @State var vsc = CustomVSC.shared
    
    var body: some View {
        VStack {
            Text("Time: \(vsc.time)")
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .font(.title)
                .padding()
            GameView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
