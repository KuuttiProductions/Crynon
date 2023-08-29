
import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var core: Core
    @Environment (\.colorScheme) private var colorMode
    
    var body: some View {
        VStack {
            GameView()
                .onAppear() {
                    updateColorScheme()
                }
        }
    }
    
    func updateColorScheme() {
        if colorMode == .light {
            Preferences.clearColor = MTLClearColor(red: 0, green: 0.2, blue: 1.0, alpha: 1.0)
        } else if colorMode == .dark {
            Preferences.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
