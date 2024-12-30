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
            // Base rates for different types
            let baseRate: Double
            if type == "Shooter" {
                baseRate = max(5.0 / Double(currentPhase), 1.5) // Slower rate for Shooters
            } else {
                baseRate = max(2.0 / Double(currentPhase), 0.5) // Faster rate for other types
            }
            
            let randomOffset = Double.random(in: -0.2...0.2)
            targetSpawnRates[type] = max(baseRate + randomOffset, 0.5)

            // Gradually adjust towards the target
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
                let spawnProbability = max(0.1, 0.3 - (0.05 * Double(currentSettings.currentPhase ?? 1))) // Reduce chance as phase increases
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
        if healthPackSpawnTimer >= healthPackSpawnRate {
            if let gameScene = scene as? GameScene,
               gameScene.player.health < gameScene.player.maxHealth { // Only spawn if player needs healing
                let healthPack = spawnHealthPack(in: gameScene)
                delegate?.didSpawnHealthPack(healthPack)
            }
            healthPackSpawnTimer = 0 // Reset the timer
        }
    }

    private func spawnEntity(ofType type: String, currentSettings: PhaseSettings) {
        guard let scene = scene else { return }

        switch type {
        case "Basic":
            let obstacle = spawnObstacle(in: scene)
            delegate?.didSpawnObstacle(obstacle)
        case "Shooter":
            let baseSpeedMultiplier: CGFloat = 0.5 // Reduce the base speed
            let speedMultiplier: CGFloat = CGFloat.random(in: baseSpeedMultiplier...(baseSpeedMultiplier + (CGFloat(currentSettings.currentPhase!) * 0.5)))
            let shooter = spawnShootingEnemy(in: scene, speedMultiplier: speedMultiplier)
            delegate?.didSpawnShootingEnemy(shooter)
        case "FastMover":
            let fastMover = spawnFastMoverEnemy(in: scene)
            delegate?.didSpawnFastMoverEnemy(fastMover)
        default:
            break
        }
    }
    
    func notifyBulletSpawn(from position: CGPoint, to target: CGPoint, bullet: BulletEntity) {
        delegate?.didSpawnBullet(bullet) // Notify delegate about the spawned bullet
    }

    private func spawnObstacle(in scene: SKScene) -> ObstacleEntity {
        let size = CGSize(width: 30, height: 30)
        let obstacle = ObstacleEntity(scene: scene, difficultyFactor: difficultyFactor, size: size)
        return obstacle
    }

    private func spawnShootingEnemy(in scene: SKScene, speedMultiplier: CGFloat) -> ShootingEnemyEntity {
        let shooter = ShootingEnemyEntity(scene: scene, difficultyFactor: difficultyFactor * speedMultiplier)
        // Assign the SpawnManager to the ShooterComponent
        if let shooterComponent = shooter.getComponent(ofType: ShooterComponent.self) {
            shooterComponent.spawnManager = self // Assign SpawnManager
        }
        return shooter
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
    func didSpawnObstacle(_ obstacle: ObstacleEntity)
    func didSpawnShootingEnemy(_ shootingEnemy: ShootingEnemyEntity)
    func didSpawnFastMoverEnemy(_ fastMoverEnemy: FastMoverEnemyEntity)
    func didSpawnBullet(_ bullet: BulletEntity)
    func didSpawnHealthPack(_ healthPack: HealthPackEntity)
}
