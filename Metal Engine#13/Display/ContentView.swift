
import SwiftUI

struct ContentView: View {
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            GameView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
