import RealityKit
import Foundation

/// Spins the diorama island slowly on the Y axis.
public struct SpinComponent: Component {
    public var speed: Float
    public var angle: Float
    public init(speed: Float = 0.5, angle: Float = 0) {
        self.speed = speed
        self.angle = angle
    }
}

struct SpinSystem: System {
    static let query = EntityQuery(where: .has(SpinComponent.self))
    init(scene: RealityKit.Scene) {}
    func update(context: SceneUpdateContext) {
        let dt = Float(context.deltaTime)
        for entity in context.scene.performQuery(Self.query) {
            guard var spin = entity.components[SpinComponent.self] else { continue }
            spin.angle += spin.speed * dt
            entity.orientation = simd_quatf(angle: spin.angle, axis: [0, 1, 0])
            entity.components.set(spin)
        }
    }
}
