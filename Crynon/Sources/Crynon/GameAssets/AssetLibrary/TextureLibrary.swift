
import MetalKit

public class TextureLibrary: Library<String, MTLTexture> {
    
    private var textureLoader = TextureLoader()
    private var _library: [String : MTLTexture] = [:]
    
    override func fillLibrary() {
        _library.updateValue(textureLoader.loadTexture("Wallpaper", "jpeg", true, engineContent: true), forKey: "Wallpaper")
        _library.updateValue(textureLoader.loadTexture("Grass", "png", true, engineContent: true), forKey: "Grass")
        _library.updateValue(textureLoader.loadTexture("Window", engineContent: true), forKey: "Window")
        _library.updateValue(textureLoader.loadTexture("OceanSky", engineContent: true), forKey: "OceanSky")
    }
    
    public func addTexture(textureName: String) {
        _library.updateValue(textureLoader.loadTexture(textureName, engineContent: false), forKey: textureName)
    }
    
    override subscript(type: String) -> MTLTexture! {
        _library[type]
    }
    
    func addTexture(_ texture: MTLTexture!, key: String) {
        _library.updateValue(texture, forKey: key)
    }
}
