# Crynon

## About ##
Crynon is a game-engine made with Swift and Metal. It's emphasis is on procedural worlds and physics and features high fidelity graphics.

Expected time of first beta release in 2025

Updates are posted on Youtube: [KudeKube](https://www.youtube.com/channel/UCXDI-MFA_Gp8vXyaJ80Zc5Q)
View roadmap on [Trello](https://trello.com/b/eskU0MZE/crynon)

## Setting up ##

Installation
1. Open your project that uses SwiftUI
2. Add Crynon package to your project with Xcode package manager. You will need a key to do this.
3. Import Crynon to your file to start using it

Setting up your project
4. Initialize Crynon.core
5. Change scene with SceneManager.changeScene(_: scene)
6. Add DefaultView or a custom GameView to your view.

## Plans ##
Here are the current plans for Crynon. Actual roadmap on Trello.

### Rendering ###
- [x] Efficient 3D renderer
- [x] Dynamic Shadows
- [ ] MetalFX support
- [ ] HDR Output
- [x] SSAO
- [ ] Post-processing
    - [x] Bloom
    - [ ] Depth Of Field
    - [ ] Motion Blur
- [ ] Mesh shading pipeline
- [ ] PBR Shaders
- [x] Transparency and translucency

### Gameloops ###
- [x] High-level object system
    - [x] Cameras
    - [x] Lights
    - [ ] Player Controllers
    - [ ] Physics Objects (WIP)

### Physics ###
- [x] Motion Dynamics
- [x] Collision Detection
- [ ] Collision Solving (Simple solution implemented)
- [x] Ray casting (Only AABBs at the moment)
- [ ] AABB Broadphase
- [ ] Stability Improvements
- [ ] Performace Optimizations
 
### Input System ###
- [x] Input
    - [x] Keyboard and Mouse
    - [x] Game Controllers
    - [x] Event Based Input
- [ ] Haptics
    - [x] Haptic playback
    - [ ] Haptic customization

### Terrain Generation ###
- [ ] Generating detailed terrain
- [ ] Planets
- [ ] Terrain physics
    
### Audio ###
- [ ] Sound effects
- [ ] Music system
