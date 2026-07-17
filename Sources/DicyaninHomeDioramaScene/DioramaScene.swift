import Foundation
import simd

// MARK: - Season / palette

/// Palette preset for the nature diorama. Drives foliage, ground, and accent
/// colors so one scene can read as summer, autumn, or winter.
public enum DioramaSeason: String, CaseIterable, Identifiable, Sendable {
    case summer, autumn, winter

    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .summer: return "Summer"
        case .autumn: return "Autumn"
        case .winter: return "Winter"
        }
    }

    var groundColor: SIMD3<Float> {
        switch self {
        case .summer: return [0.28, 0.42, 0.20]
        case .autumn: return [0.42, 0.32, 0.16]
        case .winter: return [0.82, 0.86, 0.92]
        }
    }
    var groundAccent: SIMD3<Float> {
        switch self {
        case .summer: return [0.34, 0.50, 0.24]
        case .autumn: return [0.52, 0.40, 0.18]
        case .winter: return [0.72, 0.78, 0.88]
        }
    }
    /// Candidate foliage colors, cycled across trees for variety.
    var foliage: [SIMD3<Float>] {
        switch self {
        case .summer: return [[0.20, 0.45, 0.22], [0.26, 0.52, 0.24], [0.16, 0.38, 0.20]]
        case .autumn: return [[0.78, 0.42, 0.12], [0.85, 0.55, 0.14], [0.62, 0.22, 0.12]]
        case .winter: return [[0.30, 0.44, 0.34], [0.88, 0.92, 0.96], [0.40, 0.52, 0.42]]
        }
    }
    var trunk: SIMD3<Float> { [0.34, 0.24, 0.16] }
    var rock: SIMD3<Float> { [0.44, 0.46, 0.48] }
    var water: SIMD3<Float> {
        switch self {
        case .summer: return [0.18, 0.42, 0.55]
        case .autumn: return [0.20, 0.38, 0.46]
        case .winter: return [0.60, 0.74, 0.82]
        }
    }
    /// Glowing pedestal rim accent.
    var accent: SIMD3<Float> {
        switch self {
        case .summer: return [0.30, 0.85, 0.55]
        case .autumn: return [0.95, 0.55, 0.15]
        case .winter: return [0.45, 0.80, 1.0]
        }
    }
}

// MARK: - Scene configuration

/// Everything tunable about the diorama. Use `.default` or build your own.
public struct DioramaConfig: Equatable, Sendable {
    public var season: DioramaSeason
    /// Number of trees scattered on the island (clamped 1...24).
    public var treeCount: Int
    /// Add a small reflective pond.
    public var pond: Bool
    /// Seed for the deterministic scatter, so a config always looks the same.
    public var seed: UInt64
    /// Rotations per second of the whole island (0 to hold still).
    public var spinSpeed: Float

    public init(season: DioramaSeason = .summer,
                treeCount: Int = 9,
                pond: Bool = true,
                seed: UInt64 = 42,
                spinSpeed: Float = 0.18) {
        self.season = season
        self.treeCount = min(max(treeCount, 1), 24)
        self.pond = pond
        self.seed = seed
        self.spinSpeed = spinSpeed
    }

    public static let `default` = DioramaConfig()

    /// Stable signature used to skip rebuilds when nothing changed.
    var signature: String {
        "\(season.rawValue)|\(treeCount)|\(pond)|\(seed)|\(spinSpeed)"
    }
}

// MARK: - Deterministic RNG (SplitMix64)

struct SplitMix64: RandomNumberGenerator {
    var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
