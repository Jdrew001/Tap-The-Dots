import SpriteKit

class SpawnManager {
    private var spawnRates: [String: TimeInterval] = [:]
    private var spawnTimers: [String: TimeInterval] = [:]
    private var targetSpawnRates: [String: TimeInterval] = [:]
    private let spawnRateChangeSpeed: TimeInterval = 0.05

    weak var scene: SKScene?
    weak var delegate: SpawnManagerDelegate?
    private let difficultyFactor: CGFloat

    private var spawnDelayTimer: TimeInterval = 0 // New spawn delay timer
    private let initialSpawnDelay: TimeInterval = 2.0 // Delay time before spawning

    init(scene: SKScene, difficultyFactor: CGFloat = 1.0) {
        self.scene = scene
        self.difficultyFactor = difficultyFactor
        
        ["Basic", "Shooter", "FastMover"].forEach {
            spawnRates[$0] = 1.0
            spawnTimers[$0] = 0
            targetSpawnRates[$0] = 1.0
        }
    }

    func update(deltaTime: TimeInterval, currentPhase: Int, currentSettings: PhaseSettings) {
        if spawnDelayTimer > 0 {
            // Decrease the spawn delay timer
            spawnDelayTimer -= deltaTime
            return // Skip spawning during the delay period
        }

        adjustSpawnRates(deltaTime: deltaTime, currentPhase: currentPhase)
        spawnEntities(deltaTime: deltaTime, currentSettings: currentSettings)
    }

    func resetSpawnDelay() {
        spawnDelayTimer = initialSpawnDelay // Reset the delay timer to the initial value
    }

    private func adjustSpawnRates(deltaTime: TimeInterval, currentPhase: Int) {
        for type in spawnRates.keys {
            let baseRate = max(1.0 / Double(currentPhase), 0.3)
            let randomOffset = Double.random(in: -0.1...0.1)
            targetSpawnRates[type] = max(baseRate + randomOffset, 0.2)

            if spawnRates[type]! > targetSpawnRates[type]! {
                spawnRates[type]! -= spawnRateChangeSpeed * deltaTime
                spawnRates[type]! = max(spawnRates[type]!, targetSpawnRates[type]!)
            } else if spawnRates[type]! < targetSpawnRates[type]! {
                spawnRates[type]! += spawnRateChangeSpeed * deltaTime
                spawnRates[type]! = min(spawnRates[type]!, targetSpawnRates[type]!)
            }
        }
    }

    private func spawnEntities(deltaTime: TimeInterval, currentSettings: PhaseSettings) {
        for type in currentSettings.enemyTypes {
            spawnTimers[type]! += deltaTime
            if spawnTimers[type]! >= spawnRates[type]! {
                spawnEntity(ofType: type, currentSettings: currentSettings)
                spawnTimers[type] = 0
            }
        }
    }

    private func spawnEntity(ofType type: String, currentSettings: PhaseSettings) {
        guard let scene = scene else { return }

        switch type {
        case "Basic":
            let obstacle = spawnObstacle(in: scene)
            delegate?.didSpawnObstacle(obstacle)
        case "Shooter":
            let speedMultiplier: CGFloat = CGFloat.random(in: 1.0...(CGFloat(currentSettings.currentPhase!) * 1.5))
            let shooter = spawnShootingEnemy(in: scene, speedMultiplier: speedMultiplier)
            delegate?.didSpawnShootingEnemy(shooter)
        case "FastMover":
            let fastMover = spawnFastMoverEnemy(in: scene)
            delegate?.didSpawnFastMoverEnemy(fastMover)
        default:
            break
        }
    }

    private func spawnObstacle(in scene: SKScene) -> ObstacleEntity {
        let size = CGSize(width: 30, height: 30)
        let obstacle = ObstacleEntity(scene: scene, difficultyFactor: difficultyFactor, size: size)
        return obstacle
    }

    private func spawnShootingEnemy(in scene: SKScene, speedMultiplier: CGFloat) -> ShootingEnemyEntity {
        let shooter = ShootingEnemyEntity(scene: scene, difficultyFactor: difficultyFactor * speedMultiplier)
        return shooter
    }

    private func spawnFastMoverEnemy(in scene: SKScene) -> FastMoverEnemyEntity {
        let fastMover = FastMoverEnemyEntity(scene: scene, difficultyFactor: difficultyFactor)
        return fastMover
    }
}

protocol SpawnManagerDelegate: AnyObject {
    func didSpawnObstacle(_ obstacle: ObstacleEntity)
    func didSpawnShootingEnemy(_ shootingEnemy: ShootingEnemyEntity)
    func didSpawnFastMoverEnemy(_ fastMoverEnemy: FastMoverEnemyEntity)
    func didSpawnBullet(_ bullet: BulletEntity)
}
