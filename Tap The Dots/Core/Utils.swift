import SpriteKit
import GameplayKit

struct GameUtils {
    /// Generate a random neon color.
    static func randomNeonColor() -> SKColor {
        let neonColors: [SKColor] = [
            .cyan,
            .magenta,
            .yellow,
            .green,
            .orange,
            .red
        ]
        return neonColors.randomElement() ?? .cyan
    }
}

struct PhaseSettings {
    var currentPhase: Int? // The current phase number
    var obstacleSpeed: Int
    var enemyTypes: [String] // List of enemy types active in this phase
}

struct PerlinNoise {
    private let randomSource: GKARC4RandomSource
    private let noiseScale: CGFloat

    init(seed: UInt64, noiseScale: CGFloat) {
        let seedData = withUnsafeBytes(of: seed) { Data($0) } // Convert UInt64 to Data
        self.randomSource = GKARC4RandomSource(seed: seedData)
        self.noiseScale = noiseScale
    }

    func noise(x: CGFloat, y: CGFloat) -> CGFloat {
        let adjustedX = Int((x * noiseScale).rounded())
        let adjustedY = Int((y * noiseScale).rounded())

        let hash = adjustedX ^ adjustedY
        randomSource.seed = withUnsafeBytes(of: hash) { Data($0) } // Hash converted to Data
        return CGFloat(randomSource.nextUniform()) * 2 - 1 // Scale to range [-1, 1]
    }
}
