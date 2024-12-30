import Foundation

class PhaseManager {
    static let shared = PhaseManager()

    private(set) var currentPhase: Int = 1 // Start at phase one
    private var elapsedTime: TimeInterval = 0

    // Randomize entity types and speeds for each phase
    func getSettings(for phase: Int) -> PhaseSettings {
        let enemyTypesPool = ["Basic", "FastMover", "Shooter", "HealthPack"]
        
        // Limit enemy types based on phase progression
        let maxEnemyCount = max(2, min(phase + 1, enemyTypesPool.count)) // Ensure at least 2 types
        let selectedEnemyTypes = enemyTypesPool.shuffled().prefix(maxEnemyCount)

        // Base speed scales with phase progression
        let baseSpeed = 150 + (phase * 50)
        let randomSpeed = Int.random(in: baseSpeed...(baseSpeed + 50)) // Slightly tighter range for better scaling

        return PhaseSettings(
            currentPhase: phase,
            obstacleSpeed: randomSpeed,
            enemyTypes: Array(selectedEnemyTypes)
        )
    }
    
    // Advance to the next phase based on elapsed time or conditions
    func updatePhase(deltaTime: TimeInterval) {
        elapsedTime += deltaTime
        if elapsedTime > 25 + Double(currentPhase * 5) { // Increase phase duration dynamically
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
