
import SwiftUI

typealias SwiftScene = SwiftUI.Scene

@main
struct MetalEngine13App: App {
    
    var body: some SwiftScene {
        WindowGroup {
            ContentView()
                .presentedWindowStyle(.hiddenTitleBar)
        }
    }
}
