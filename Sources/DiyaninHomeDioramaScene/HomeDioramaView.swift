import SwiftUI
import RealityKit

/// Registers the components and systems the diorama needs. Safe to call more
/// than once. `HomeDioramaView` calls this automatically, but you can call it
/// yourself from app launch if you prefer.
@MainActor
public enum DiyaninHomeDioramaScene {
    private static var registered = false
    public static func register() {
        guard !registered else { return }
        registered = true
        SpinComponent.registerComponent()
        HomeDioramaBuilder.Signature.registerComponent()
        SpinSystem.registerSystem()
    }
}

/// Drop-in low poly nature island diorama.
///
/// - visionOS: sized for the default volume; place inside a `WindowGroup`
///   with `.windowStyle(.volumetric)`.
/// - iOS: fills the view with an orbit-controllable RealityView.
///
/// Pass a `config` to change season, tree count, pond, and spin. Passing a new
/// value rebuilds the island.
public struct HomeDioramaView: View {
    private let config: DioramaConfig

    public init(config: DioramaConfig = .default) {
        self.config = config
    }

    public var body: some View {
        content.onAppear { DiyaninHomeDioramaScene.register() }
    }

    @ViewBuilder private var content: some View {
        #if os(visionOS)
        RealityView { content in
            let root = Entity()
            root.name = "homeDiorama"
            root.position = [0, -0.20, 0]
            HomeDioramaBuilder.build(into: root, config: config)
            content.add(root)
        } update: { content in
            guard let root = content.entities.first(where: { $0.name == "homeDiorama" }) else { return }
            HomeDioramaBuilder.build(into: root, config: config)
        }
        #else
        RealityView { content in
            let root = Entity()
            root.name = "homeDiorama"
            root.position = [0, -0.15, -0.85]
            HomeDioramaBuilder.build(into: root, config: config)
            content.add(root)
        } update: { content in
            guard let root = content.entities.first(where: { $0.name == "homeDiorama" }) else { return }
            HomeDioramaBuilder.build(into: root, config: config)
        }
        .realityViewCameraControls(.orbit)
        #endif
    }
}
