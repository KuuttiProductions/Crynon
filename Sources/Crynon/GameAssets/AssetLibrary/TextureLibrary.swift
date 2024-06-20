
import MetalKit

public class TextureLibrary: Library<String, MTLTexture> {
    
    private var textureLoader = TextureLoader()
    private var _library: [String : MTLTexture] = [:]
    
    override func fillLibrary() {
        
    }
    
    public func addTexture(textureName: String, ext: String = "png", mipMaps: Bool = true, origin: TextureOrigin = .bottomLeft, srgb: Bool = false) {
        _library.updateValue(textureLoader.loadTexture(name: textureName, extension: ext, mipMaps: mipMaps, origin: origin, srgb: srgb, engineContent: false), forKey: textureName)
    }
    
    override subscript(type: String) -> MTLTexture! {
        _library[type]
    }
    
    func addTexture(_ texture: MTLTexture!, key: String) {
        _library.updateValue(texture, forKey: key)
    }
    
    func addTextureMDL(_ texture: MDLTexture!)-> String {
        let key = UUID().uuidString
        if let tex = texture {
            let output = textureLoader.loadTextureFromTexture(mdlTexture: texture,
                                                              mipMaps: true,
                                                              origin: .bottomLeft)
            _library.updateValue(output, forKey: key)
            return key
        } else { return "" }
    }
}
