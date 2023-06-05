
class AssetLibrary {

    private static var _meshLibrary: MeshLibrary!
    public static var meshes: MeshLibrary { return _meshLibrary }
    
    static func initialize() {
        _meshLibrary = MeshLibrary()
    }
}
