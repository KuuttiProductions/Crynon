
import MetalKit

public class TextureLibrary: Library<String, MTLTexture> {
    
    private var textureLoader = TextureLoader()
    private var _library: [String : MTLTexture] = [:]
    
    override func fillLibrary() {
        
    }
    
    public func addTexture(textureName: String, ext: String = "png", mipMaps: Bool = true, origin: TextureOrigin = .bottomLeft) {
        _library.updateValue(textureLoader.loadTexture(name: textureName, extension: ext, mipMaps: mipMaps, origin: origin, engineContent: false), forKey: textureName)
    }
    
    override subscript(type: String) -> MTLTexture! {
        _library[type]
    }
    
    func addTexture(_ texture: MTLTexture!, key: String) {
        _library.updateValue(texture, forKey: key)
    }
}
