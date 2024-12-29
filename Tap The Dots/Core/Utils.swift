import SpriteKit

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
