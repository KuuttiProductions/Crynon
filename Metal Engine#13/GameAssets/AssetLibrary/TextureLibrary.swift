
import MetalKit

class TextureLibrary: Library<String, MTLTexture> {
    
    private var textureLoader = TextureLoader()
    private var _library: [String : MTLTexture] = [:]
    
    override func fillLibrary() {
        _library.updateValue(textureLoader.loadTexture("Wallpaper", "jpeg", true), forKey: "Wallpaper")
        _library.updateValue(textureLoader.loadTexture("Grass", "png", true), forKey: "Grass")
        _library.updateValue(textureLoader.loadTexture("Window"), forKey: "Window")
    }
    
    override subscript(type: String) -> MTLTexture! {
        _library[type]
    }
    
    func addTexture(_ texture: MTLTexture!, key: String) {
        _library.updateValue(texture, forKey: key)
    }
}
