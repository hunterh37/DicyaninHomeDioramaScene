# DicyaninHomeDioramaScene

A drop-in RealityKit "home diorama" scene: a low poly nature island floating on
a glowing pedestal, slowly spinning, with a scatter of trees, rocks, grass, and
an optional pond. Works on visionOS (volumetric) and iOS (orbit camera).
No assets, no `.usdz`, no `.rcproject`: all geometry is generated from
primitives, so the whole thing is a few kilobytes of Swift.

## Install

Swift Package Manager.

Xcode: File > Add Package Dependencies > Add Local... and select this folder,
or point at the git URL once it is pushed. Then add the
`DicyaninHomeDioramaScene` library to your app target.

`Package.swift`:

```swift
.package(url: "https://github.com/<you>/DicyaninHomeDioramaScene.git", from: "1.0.0"),
// then in your target dependencies:
.product(name: "DicyaninHomeDioramaScene", package: "DicyaninHomeDioramaScene")
```

Requirements: iOS 18 / visionOS 2, Swift 6.

## Usage

```swift
import SwiftUI
import DicyaninHomeDioramaScene

struct ContentView: View {
    var body: some View {
        HomeDioramaView()   // summer island, default scatter
    }
}
```

Customize the scene:

```swift
let config = DioramaConfig(
    season: .autumn,   // .summer, .autumn, .winter
    treeCount: 14,     // clamped 1...24
    pond: true,
    seed: 7,           // deterministic scatter; same seed => same island
    spinSpeed: 0.12    // rotations/sec, 0 to hold still
)
HomeDioramaView(config: config)
```

`DioramaSeason` recolors foliage, ground, water, and the pedestal rim glow.
The scatter is fully deterministic from `seed`, so a given config always renders
the same island.

### visionOS (volumetric window)

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup { HomeDioramaView() }
            .windowStyle(.volumetric)
            .defaultSize(width: 0.8, height: 0.7, depth: 0.8, in: .meters)
    }
}
```

The scene is grounded with a constant transform. If you use a very different
volume size, adjust the root `position` in `HomeDioramaView`, or wrap the view
and offset it yourself.

### iOS (window)

`HomeDioramaView()` fills its frame and enables an orbit camera. Give it a dark
background for contrast:

```swift
ZStack {
    Color.black.ignoresSafeArea()
    HomeDioramaView().ignoresSafeArea()
}
```

## Info.plist reminders

This scene renders its own generated geometry. It does NOT use the camera,
ARKit scene reconstruction, hand tracking, or passthrough sensing, so it needs
no usage-description permissions on its own.

visionOS:

- No `NSWorldSensingUsageDescription` or hand-tracking keys required for the
  diorama. Add them only if the rest of your app uses those features.
- Volumetric presentation is set via the `WindowGroup` style shown above; there
  is no Info.plist key for it.

iOS:

- Metal-capable device required. The Simulator renders RealityKit from Xcode 15+,
  but a physical device is recommended.
- `UIRequiredDeviceCapabilities` should include `arm64` (default for modern
  projects).
- Add `NSCameraUsageDescription` only if you later anchor this content to the
  camera / AR. The bundled diorama does not need it.

General:

- Minimum deployment target iOS 18.0 / visionOS 2.0 (RealityView + orbit camera
  controls). Set `IPHONEOS_DEPLOYMENT_TARGET` / `XROS_DEPLOYMENT_TARGET`
  accordingly, or SPM resolution will fail.

## Registration

`HomeDioramaView` registers its component and system automatically on first
appear. If you build the diorama manually (see below) before showing the view,
call this once at launch:

```swift
DicyaninHomeDioramaScene.register()
```

## Building into your own RealityView

Skip `HomeDioramaView` and place the diorama in an existing scene:

```swift
DicyaninHomeDioramaScene.register()

let root = Entity()
root.name = "homeDiorama"
HomeDioramaBuilder.build(into: root, config: .default)
myContent.add(root)

// Later, to rebuild after the config changes:
HomeDioramaBuilder.build(into: root, config: newConfig)
```

`build` is cheap to call every frame: it early-outs unless the config signature
changed.

## Public API

- `HomeDioramaView(config:)` : SwiftUI view.
- `DioramaConfig` : `.default`, `init(season:treeCount:pond:seed:spinSpeed:)`.
- `DioramaSeason` : `.summer`, `.autumn`, `.winter`.
- `HomeDioramaBuilder.build(into:config:)`.
- `SpinComponent`.
- `DicyaninHomeDioramaScene.register()`.
