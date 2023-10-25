
import Foundation

@Observable
class CustomVSC: ViewStateCenter {
    static var shared = CustomVSC()
    
    var time: Float = 0.0
}
