
import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var core: Core
    @Environment (\.colorScheme) private var colorMode
    
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
