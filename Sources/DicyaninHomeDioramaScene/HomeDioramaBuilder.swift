import RealityKit
import UIKit

/// Builds a low poly nature island diorama into a root entity: a glowing
/// pedestal, a rounded grass island, and a deterministic scatter of trees,
/// rocks, grass, and an optional pond. The island slowly spins.
@MainActor
public enum HomeDioramaBuilder {
    struct Signature: Component { var value: String }

    static let islandRadius: Float = 0.30

    public static func build(into root: Entity, config: DioramaConfig) {
        // The update closure fires constantly: skip unless the config changed.
        if root.components[Signature.self]?.value == config.signature { return }
        root.components.set(Signature(value: config.signature))

        root.findEntity(named: "pedestal")?.removeFromParent()
        root.findEntity(named: "island")?.removeFromParent()

        let pedestal = makePedestal(season: config.season)
        pedestal.name = "pedestal"
        root.addChild(pedestal)

        let island = Entity()
        island.name = "island"
        island.position = [0, 0.04, 0]
        island.components.set(SpinComponent(speed: config.spinSpeed))
        buildIsland(into: island, config: config)
        root.addChild(island)
    }

    // MARK: Pedestal

    private static func makePedestal(season: DioramaSeason) -> Entity {
        let root = Entity()
        let r = islandRadius * 1.2
        var top = SimpleMaterial()
        top.color = .init(tint: UIColor(white: 0.16, alpha: 1))
        top.metallic = 0.7
        top.roughness = 0.4
        root.addChild(NatureMesh.cyl(r, 0.03, top, at: [0, -0.015, 0]))
        root.addChild(NatureMesh.cyl(r * 1.12, 0.05, NatureMesh.matte([0.10, 0.10, 0.11], rough: 0.6),
                                     at: [0, -0.055, 0]))
        let rim = NatureMesh.cyl(r * 1.02, 0.012, NatureMesh.glow(season.accent), at: [0, 0.006, 0])
        root.addChild(rim)
        return root
    }

    // MARK: Island

    private static func buildIsland(into island: Entity, config: DioramaConfig) {
        let season = config.season
        var rng = SplitMix64(seed: config.seed)
        let r = islandRadius

        // Grass cap: a squashed sphere top forms a soft mound.
        let cap = NatureMesh.sphere(r, NatureMesh.matte(season.groundColor))
        cap.scale = [1.0, 0.28, 1.0]
        cap.position = [0, 0, 0]
        island.addChild(cap)

        // Dirt underside.
        let dirt = NatureMesh.cone(r * 0.98, r * 0.9, NatureMesh.matte(season.groundAccent * 0.7, rough: 1.0))
        dirt.orientation = simd_quatf(angle: .pi, axis: [1, 0, 0])
        dirt.position = [0, -r * 0.32, 0]
        island.addChild(dirt)

        // Optional pond, placed off center.
        var pondCenter = SIMD2<Float>(0, 0)
        var pondR: Float = 0
        if config.pond {
            pondR = r * 0.30
            pondCenter = SIMD2(-r * 0.28, r * 0.10)
            let water = NatureMesh.cyl(pondR, 0.008, NatureMesh.waterMat(season.water),
                                       at: [pondCenter.x, 0.055, pondCenter.y])
            island.addChild(water)
        }

        let foliage = season.foliage
        var placed: [SIMD2<Float>] = []

        func clearOfPond(_ p: SIMD2<Float>) -> Bool {
            pondR == 0 || simd_distance(p, pondCenter) > pondR + 0.03
        }
        func clearOfOthers(_ p: SIMD2<Float>, _ minD: Float) -> Bool {
            placed.allSatisfy { simd_distance(p, $0) > minD }
        }
        func scatterPoint(maxR: Float) -> SIMD2<Float> {
            let ang = Float.random(in: 0..<(2 * .pi), using: &rng)
            let rad = maxR * sqrt(Float.random(in: 0..<1, using: &rng))
            return SIMD2(cos(ang) * rad, sin(ang) * rad)
        }

        // Trees.
        var attempts = 0
        var treesPlaced = 0
        while treesPlaced < config.treeCount && attempts < config.treeCount * 12 {
            attempts += 1
            let p = scatterPoint(maxR: r * 0.82)
            guard clearOfPond(p), clearOfOthers(p, 0.055) else { continue }
            placed.append(p)
            treesPlaced += 1

            let y = groundHeight(at: p, r: r)
            let fam = foliage[Int(rng.next() % UInt64(foliage.count))]
            let height = Float.random(in: 0.10...0.17, using: &rng)
            let usePine = (rng.next() & 1) == 0
            let tree = usePine
                ? NatureMesh.pine(foliage: fam, trunk: season.trunk, height: height)
                : NatureMesh.broadleaf(foliage: fam, trunk: season.trunk, height: height)
            tree.position = [p.x, y, p.y]
            tree.orientation = simd_quatf(angle: Float.random(in: 0..<(2 * .pi), using: &rng), axis: [0, 1, 0])
            island.addChild(tree)
        }

        // Rocks.
        for _ in 0..<3 {
            let p = scatterPoint(maxR: r * 0.85)
            guard clearOfPond(p) else { continue }
            let y = groundHeight(at: p, r: r)
            let rock = NatureMesh.rock(season.rock, size: Float.random(in: 0.018...0.032, using: &rng))
            rock.position = [p.x, y, p.y]
            island.addChild(rock)
        }

        // Grass tufts.
        for _ in 0..<10 {
            let p = scatterPoint(maxR: r * 0.9)
            guard clearOfPond(p) else { continue }
            let y = groundHeight(at: p, r: r)
            let tuft = NatureMesh.grass(foliage[Int(rng.next() % UInt64(foliage.count))])
            tuft.position = [p.x, y, p.y]
            island.addChild(tuft)
        }
    }

    /// Surface height of the squashed grass cap at planar radius from center.
    private static func groundHeight(at p: SIMD2<Float>, r: Float) -> Float {
        let d = min(simd_length(p) / r, 1)
        return 0.28 * r * sqrt(max(0, 1 - d * d)) - 0.002
    }
}
