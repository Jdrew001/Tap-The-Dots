import Foundation

class PhaseManager {
    static let shared = PhaseManager()

    private(set) var currentPhase: Int = 1 // Start at phase one
    private var elapsedTime: TimeInterval = 0

    // Randomize entity types and speeds for each phase
    func getSettings(for phase: Int) -> PhaseSettings {
        let enemyTypesPool = ["Basic", "FastMover", "Shooter", "HealthPack"]
        let maxEnemyCount = min(phase + 1, enemyTypesPool.count)
        let selectedEnemyTypes = enemyTypesPool.shuffled().prefix(maxEnemyCount)

        let baseSpeed = 200 + (phase * 50) // Increase speed as the phase progresses
        let randomSpeed = Int.random(in: baseSpeed...(baseSpeed + 100)) // Randomize within a range

        return PhaseSettings(
            currentPhase: phase,
            obstacleSpeed: randomSpeed,
            enemyTypes: Array(selectedEnemyTypes)
        )
    }
    
    // Advance to the next phase based on elapsed time or conditions
    func updatePhase(deltaTime: TimeInterval) {
        elapsedTime += deltaTime
        if elapsedTime > 30 { // Example: Change phase every 30 seconds
            currentPhase += 1
            elapsedTime = 0 // Reset timer for the next phase
            print("Advanced to phase \(currentPhase)")
        }
    }
    
    func reset() {
        currentPhase = 1
        elapsedTime = 0
    }
}
