
import MetalKit
import SwiftUI

typealias Prefs = Preferences

public class Preferences {
    
    private static var _corePreferences: CorePreferences!
    public static var core: CorePreferences { return _corePreferences }
    
    private static var _metalPreferences: MetalPreferences!
    static var metal: MetalPreferences { return _metalPreferences }
    
    private static var _graphicsPreferences: GraphicsPreferences!
    public static var graphics: GraphicsPreferences { return _graphicsPreferences }
    
    private static var _physicsPreferences: PhysicsPreferences!
    public static var physics: PhysicsPreferences { return _physicsPreferences }
    
    private static var _audioPreferences: AudioPreferences!
    public static var audio: AudioPreferences { return _audioPreferences }
    
    static func initialize() {
        _corePreferences = CorePreferences()
        _graphicsPreferences = GraphicsPreferences()
        _metalPreferences = MetalPreferences()
        _physicsPreferences = PhysicsPreferences()
        _audioPreferences = AudioPreferences()
    }
}
