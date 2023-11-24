
import SwiftUI

public struct DefaultView: View {
        
    public init() {}
    
    public var body: some View {
        VStack {
            GameView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultView()
    }
}
