
public class AssetLibrary {

    private static var _meshLibrary: MeshLibrary!
    public static var meshes: MeshLibrary { _meshLibrary }
    
    private static var _textureLibrary: TextureLibrary!
    public static var textures: TextureLibrary { _textureLibrary }
    
    static func initialize() {
        _textureLibrary = TextureLibrary()
        _meshLibrary = MeshLibrary()
    }
}
