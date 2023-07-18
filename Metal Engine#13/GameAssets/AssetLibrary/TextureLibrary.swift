
import MetalKit

class TextureLibrary: Library<String, MTLTexture> {
    
    private var _library: [String : MTLTexture] = [:]
    
    override func fillLibrary() {
//        _library.updateValue(, forKey: )
    }
    
    override subscript(type: String) -> MTLTexture! {
        _library[type]
    }
    
    func addTexture(_ texture: MTLTexture!, key: String) {
        _library.updateValue(texture, forKey: key)
    }
}
