
import MetalKit

public enum TextureOrigin {
    case bottomLeft
    case topLeft
}

class TextureLoader {
    func loadTexture(name: String,
                     extension: String = "png",
                     mipMaps: Bool = true,
                     origin: TextureOrigin = .bottomLeft,
                     engineContent: Bool = false)-> MTLTexture {
        var url: URL!
        if engineContent {
            url = Bundle.module.url(forResource: name, withExtension: `extension`)!
        } else {
            url = Bundle.main.url(forResource: name, withExtension: `extension`)!
        }
        
        let loader = MTKTextureLoader(device: Core.device)
        let origin = origin == .bottomLeft ? MTKTextureLoader.Origin.bottomLeft : MTKTextureLoader.Origin.topLeft
        let options: [ MTKTextureLoader.Option : Any ] = [MTKTextureLoader.Option.generateMipmaps : mipMaps,
                                                          MTKTextureLoader.Option.textureStorageMode : MTLStorageMode.shared.rawValue,
                                                          MTKTextureLoader.Option.origin : origin]
        var texture: MTLTexture!
        
        do {
            texture = try loader.newTexture(URL: url, options: options)
        } catch let error {
            print("Error loading texture: \(error)")
        }
        
        texture.label = name
        
        return texture
    }
    
    func loadTextureFromTexture(mdlTexture: MDLTexture, mipMaps: Bool, origin: TextureOrigin)-> MTLTexture {
        let loader = MTKTextureLoader(device: Core.device)
        let origin = origin == .bottomLeft ? MTKTextureLoader.Origin.bottomLeft : MTKTextureLoader.Origin.topLeft
        let options: [ MTKTextureLoader.Option : Any ] = [MTKTextureLoader.Option.generateMipmaps : mipMaps,
                                                          MTKTextureLoader.Option.textureStorageMode : MTLStorageMode.shared.rawValue,
                                                          MTKTextureLoader.Option.origin : origin]
        var texture: MTLTexture!
        
        do {
            texture = try loader.newTexture(texture: mdlTexture, options: options)
        } catch let error as NSError {
            print(error)
        }
        
        texture.label = mdlTexture.name
        
        return texture
    }
}
