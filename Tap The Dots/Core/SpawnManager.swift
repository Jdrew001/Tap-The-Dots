import SpriteKit

class SpawnManager {
    private var spawnRates: [String: TimeInterval] = [:]
    private var spawnTimers: [String: TimeInterval] = [:]
    private var targetSpawnRates: [String: TimeInterval] = [:]
    private let spawnRateChangeSpeed: TimeInterval = 0.05
    private var healthPackSpawnTimer: TimeInterval = 0
    private let healthPackSpawnRate: TimeInterval = 5

    weak var scene: SKScene?
    weak var delegate: SpawnManagerDelegate?
    private let difficultyFactor: CGFloat

    private var spawnDelayTimer: TimeInterval = 0 // New spawn delay timer
    private let initialSpawnDelay: TimeInterval = 2.5 // Delay time before spawning

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
            let baseRate: Double
            if type == "Shooter" {
                baseRate = max(4.0 / Double(currentPhase), 1.0) // Slightly faster for Shooters
            } else {
                baseRate = max(1.5 / Double(currentPhase), 0.3) // Faster rates for other types
            }
            
            let randomOffset = Double.random(in: -0.15...0.15)
            targetSpawnRates[type] = max(baseRate + randomOffset, 0.2)

            if spawnRates[type]! > targetSpawnRates[type]! {
                spawnRates[type]! -= spawnRateChangeSpeed * deltaTime
            } else if spawnRates[type]! < targetSpawnRates[type]! {
                spawnRates[type]! += spawnRateChangeSpeed * deltaTime
            }
        }
    }
    
    private func spawnEntities(deltaTime: TimeInterval, currentSettings: PhaseSettings) {
        for type in currentSettings.enemyTypes {
            // Ensure spawnTimers and spawnRates are initialized
            if spawnTimers[type] == nil {
                spawnTimers[type] = 0
            }
            if spawnRates[type] == nil {
                spawnRates[type] = 1.0 // Default spawn rate
            }

            spawnTimers[type]! += deltaTime

            if type == "Shooter" {
                let spawnProbability = max(0.2, 0.5 - (0.03 * Double(currentSettings.currentPhase!))) // Keep shooters relevant // Reduce chance as phase increases
                if spawnTimers[type]! >= spawnRates[type]! && Double.random(in: 0...1) <= spawnProbability {
                    spawnEntity(ofType: type, currentSettings: currentSettings)
                    spawnTimers[type] = 0
                }
            } else if spawnTimers[type]! >= spawnRates[type]! {
                spawnEntity(ofType: type, currentSettings: currentSettings)
                spawnTimers[type] = 0
            }
        }
        
        // Handle health pack spawning separately
        healthPackSpawnTimer += deltaTime
        let dynamicHealthPackSpawnRate = max(healthPackSpawnRate - (Double(currentSettings.currentPhase ?? 1) * 0.5), 3.0)
        if healthPackSpawnTimer >= dynamicHealthPackSpawnRate {
            if let gameScene = scene as? GameScene,
               gameScene.player.health < gameScene.player.maxHealth {
                let healthPack = spawnHealthPack(in: gameScene)
                delegate?.didSpawnHealthPack(healthPack)
            }
            healthPackSpawnTimer = 0
        }
    }

    private func spawnEntity(ofType type: String, currentSettings: PhaseSettings) {
        guard let scene = scene else { return }

        switch type {
        case "Basic":
            let obstacle = spawnObstacle(in: scene)
            delegate?.didSpawnEnemy(obstacle)
        case "Shooter":
            let baseSpeedMultiplier: CGFloat = 0.5 // Reduce the base speed
            let speedMultiplier: CGFloat = CGFloat.random(in: baseSpeedMultiplier...(baseSpeedMultiplier + (CGFloat(currentSettings.currentPhase!) * 0.5)))
            let shooter = spawnShootingEnemy(in: scene, speedMultiplier: speedMultiplier, currentSettings: currentSettings)
            delegate?.didSpawnEnemy(shooter)
        case "FastMover":
            let fastMover = spawnFastMoverEnemy(in: scene)
            delegate?.didSpawnEnemy(fastMover)
        default:
            break
        }
    }
    
    func notifyBulletSpawn(from position: CGPoint, to target: CGPoint, bullet: BulletEntity) {
        delegate?.didSpawnBullet(bullet)
    }
    
    func spawnPlayerBullet(from position: CGPoint, to target: CGPoint) {
        guard let scene = scene else { return }

        let bullet = SimpleBulletEntity(scene: scene, position: position, target: target)
        delegate?.didSpawnPlayerBullet(bullet)
    }

    private func spawnObstacle(in scene: SKScene) -> ObstacleEntity {
        let size = CGSize(width: 30, height: 30)
        let obstacle = ObstacleEntity(scene: scene, difficultyFactor: difficultyFactor, size: size)
        return obstacle
    }

    private func spawnShootingEnemy(in scene: SKScene, speedMultiplier: CGFloat, currentSettings: PhaseSettings) -> ShootingEnemyEntity {
        // Define a base speed multiplier
        let baseSpeedMultiplier: CGFloat = 0.5 // Adjust this base value as needed
        
        // Calculate a phase-dependent speed bonus
        let phaseSpeedBonus = CGFloat(currentSettings.currentPhase ?? 1) * 0.2
        
        // Adjust the final speed multiplier
        let adjustedSpeedMultiplier = max(baseSpeedMultiplier + phaseSpeedBonus, 1.0)
        
        // Return a new ShootingEnemyEntity
        return ShootingEnemyEntity(scene: scene, difficultyFactor: difficultyFactor * adjustedSpeedMultiplier, spawnManager: self)
    }

    private func spawnFastMoverEnemy(in scene: SKScene) -> FastMoverEnemyEntity {
        let fastMover = FastMoverEnemyEntity(scene: scene, difficultyFactor: difficultyFactor)
        return fastMover
    }
    
    private func spawnHealthPack(in scene: SKScene) -> HealthPackEntity {
        let healthPack = HealthPackEntity(scene: scene)
        delegate?.didSpawnHealthPack(healthPack)
        return healthPack
    }
}

protocol SpawnManagerDelegate: AnyObject {
    func didSpawnEnemy(_ enemy: Entity)
    func didSpawnBullet(_ bullet: BulletEntity)
    func didSpawnPlayerBullet(_ bullet: Entity)
    func didSpawnHealthPack(_ healthPack: HealthPackEntity)
}
