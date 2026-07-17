import RealityKit
import UIKit

/// Low poly primitive construction kit for the nature diorama.
/// Every builder returns an Entity whose origin is its ground attachment point.
/// Dimensions are in meters at diorama scale (island radius ~0.32 m).
@MainActor
enum NatureMesh {

    // MARK: Materials

    static func color(_ c: SIMD3<Float>) -> UIColor {
        UIColor(red: CGFloat(c.x), green: CGFloat(c.y), blue: CGFloat(c.z), alpha: 1)
    }
    static func matte(_ c: SIMD3<Float>, rough: Float = 0.9) -> SimpleMaterial {
        var m = SimpleMaterial()
        m.color = .init(tint: color(c))
        m.metallic = 0.0
        m.roughness = .init(floatLiteral: rough)
        return m
    }
    static func glow(_ c: SIMD3<Float>) -> UnlitMaterial {
        UnlitMaterial(color: color(c))
    }
    static func waterMat(_ c: SIMD3<Float>) -> PhysicallyBasedMaterial {
        var m = PhysicallyBasedMaterial()
        m.baseColor = .init(tint: color(c).withAlphaComponent(0.72))
        m.blending = .transparent(opacity: .init(floatLiteral: 0.72))
        m.roughness = .init(floatLiteral: 0.05)
        m.metallic = .init(floatLiteral: 0.0)
        m.clearcoat = .init(floatLiteral: 1.0)
        return m
    }

    // MARK: Primitives

    static func cone(_ r: Float, _ h: Float, _ mat: RealityKit.Material, at p: SIMD3<Float> = .zero) -> ModelEntity {
        let e = ModelEntity(mesh: .generateCone(height: h, radius: r), materials: [mat])
        e.position = p
        return e
    }
    static func cyl(_ r: Float, _ h: Float, _ mat: RealityKit.Material, at p: SIMD3<Float> = .zero) -> ModelEntity {
        let e = ModelEntity(mesh: .generateCylinder(height: h, radius: r), materials: [mat])
        e.position = p
        return e
    }
    static func sphere(_ r: Float, _ mat: RealityKit.Material, at p: SIMD3<Float> = .zero) -> ModelEntity {
        let e = ModelEntity(mesh: .generateSphere(radius: r), materials: [mat])
        e.position = p
        return e
    }
    static func box(_ w: Float, _ h: Float, _ d: Float, _ mat: RealityKit.Material,
                    at p: SIMD3<Float> = .zero, yaw: Float = 0) -> ModelEntity {
        let e = ModelEntity(mesh: .generateBox(width: w, height: h, depth: d, cornerRadius: 0.004), materials: [mat])
        e.position = p
        e.orientation = simd_quatf(angle: yaw, axis: [0, 1, 0])
        return e
    }

    // MARK: Trees

    /// A stacked-cone conifer. Origin at the ground.
    static func pine(foliage: SIMD3<Float>, trunk: SIMD3<Float>, height: Float) -> Entity {
        let root = Entity()
        let bark = matte(trunk)
        let leaf = matte(foliage)
        let trunkH = height * 0.28
        root.addChild(cyl(height * 0.035, trunkH, bark, at: [0, trunkH / 2, 0]))
        let tiers = 3
        for i in 0..<tiers {
            let f = Float(i) / Float(tiers)
            let r = height * (0.20 - f * 0.10)
            let h = height * 0.34
            let y = trunkH + height * 0.16 + f * height * 0.24
            root.addChild(cone(r, h, leaf, at: [0, y, 0]))
        }
        return root
    }

    /// A rounded broadleaf tree: trunk plus a clustered canopy. Origin at ground.
    static func broadleaf(foliage: SIMD3<Float>, trunk: SIMD3<Float>, height: Float) -> Entity {
        let root = Entity()
        let bark = matte(trunk)
        let leaf = matte(foliage)
        let trunkH = height * 0.45
        root.addChild(cyl(height * 0.045, trunkH, bark, at: [0, trunkH / 2, 0]))
        let canopyY = trunkH + height * 0.18
        let r = height * 0.26
        root.addChild(sphere(r, leaf, at: [0, canopyY, 0]))
        root.addChild(sphere(r * 0.7, leaf, at: [r * 0.7, canopyY + r * 0.1, 0]))
        root.addChild(sphere(r * 0.7, leaf, at: [-r * 0.6, canopyY - r * 0.05, r * 0.3]))
        root.addChild(sphere(r * 0.6, leaf, at: [0, canopyY + r * 0.5, -r * 0.3]))
        return root
    }

    // MARK: Ground details

    /// A faceted rock. Origin at ground.
    static func rock(_ color: SIMD3<Float>, size: Float) -> Entity {
        let root = Entity()
        let mat = matte(color, rough: 0.7)
        let e = sphere(size, mat, at: [0, size * 0.55, 0])
        e.scale = [1.0, 0.7, 0.85]
        root.addChild(e)
        return root
    }

    /// A cluster of grass blades. Origin at ground.
    static func grass(_ color: SIMD3<Float>) -> Entity {
        let root = Entity()
        let mat = matte(color)
        for i in 0..<3 {
            let a = Float(i) * 2.0
            let blade = box(0.006, 0.05, 0.006, mat, at: [cos(a) * 0.01, 0.025, sin(a) * 0.01], yaw: a)
            root.addChild(blade)
        }
        return root
    }
}
