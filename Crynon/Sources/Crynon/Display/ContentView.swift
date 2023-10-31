
import SwiftUI

public struct ContentView: View {
    
    @EnvironmentObject private var core: Core
    
    public init() {
        
    }
    
    public var body: some View {
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
