
import SwiftUI

typealias SwiftScene = SwiftUI.Scene

@main
struct MetalEngine13App: App {
    
    @StateObject private var core = Core()
    
    var body: some SwiftScene {
        WindowGroup {
            ContentView().environmentObject(core)
        }
    }
}
