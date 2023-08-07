
import MetalKit

class TextureLoader {
    
    func loadTexture(_ name: String, _ extension: String = "png", _ mipMaps: Bool = true)-> MTLTexture {
        let url = Bundle.main.url(forResource: name, withExtension: `extension`)!
        let loader = MTKTextureLoader(device: Core.device)
        let options: [ MTKTextureLoader.Option : Any ] = [ MTKTextureLoader.Option.generateMipmaps : mipMaps ]
        var texture: MTLTexture!
        
        do {
            texture = try loader.newTexture(URL: url, options: options)
        } catch let error {
            print("Error loading texture: \(error)")
        }
        
        texture.label = name
        
        return texture
    }
}
