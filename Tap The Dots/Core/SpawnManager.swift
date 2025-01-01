import SpriteKit

class SpawnManager {
    private var spawnRates: [String: TimeInterval] = [:]
    private var spawnTimers: [String: TimeInterval] = [:]
    private var targetSpawnRates: [String: TimeInterval] = [:]
    private let spawnRateChangeSpeed: TimeInterval = 0.05
    private var healthPackSpawnTimer: TimeInterval = 0
    private let healthPackSpawnRate: TimeInterval = 10 // 10 seconds
    private var powerUpSpawnTimer: TimeInterval = 0
    private let powerUpSpawnRate: TimeInterval = 15.0 // 15 seconds
    var activePowerUp: PowerUpEntity.PowerUpType? // Track the active power-up
    

    weak var scene: SKScene?
    weak var delegate: SpawnManagerDelegate?
    private let difficultyFactor: CGFloat

    private var spawnDelayTimer: TimeInterval = 0 // New spawn delay timer
    private let initialSpawnDelay: TimeInterval = 2.5 // Delay time before spawning
    private var playerHasPowerUp: Bool = false
    private var powerUpTimer: TimeInterval = 0

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
        handlePowerUpSpawning(deltaTime: deltaTime)
        checkPowerUpDuration(deltaTime: deltaTime)
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
                // Probability increases with the phase number
                let spawnProbability = min(0.05 + (0.05 * Double(currentSettings.currentPhase!)), 0.8)
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
        let baseSpeedMultiplier: CGFloat = 1.0 // Maximum speed multiplier

        // Calculate a phase-dependent speed reduction
        let phasePenalty = min(CGFloat(currentSettings.currentPhase ?? 1) * 0.05, 0.5) // Cap the penalty at 50%

        // Adjust the final speed multiplier
        let adjustedSpeedMultiplier = max(baseSpeedMultiplier - phasePenalty, 0.5) // Ensure minimum speed multiplier is 0.5
        
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
    
    private func handlePowerUpSpawning(deltaTime: TimeInterval) {
        powerUpSpawnTimer += deltaTime
        if powerUpSpawnTimer >= powerUpSpawnRate {
            powerUpSpawnTimer = 0
            spawnPowerUp()
        }
    }

    private func spawnPowerUp() {
        guard let scene = scene else { return }

        let randomX = CGFloat.random(in: 50...(scene.size.width - 50))
        let randomY = CGFloat.random(in: 50...(scene.size.height - 50))
        let position = CGPoint(x: randomX, y: randomY)

        let powerUpTypes: [PowerUpEntity.PowerUpType] = [.explosiveBullet, .shield, .tripleShot, .slowTime]
        let randomType = powerUpTypes.randomElement()!

        let powerUp = PowerUpEntity(scene: scene, position: position, type: randomType)
        delegate?.didSpawnPowerUp(powerUp)
    }

    private func checkPowerUpDuration(deltaTime: TimeInterval) {
        if powerUpTimer > 0 {
            powerUpTimer -= deltaTime
            if powerUpTimer <= 0 {
                activePowerUp = nil // Deactivate the power-up when time runs out
            }
        }
    }

    func activatePowerUp(duration: TimeInterval) {
        playerHasPowerUp = true
        powerUpTimer = duration
    }
    
    func activateExplosiveBullets(duration: TimeInterval) {
        activePowerUp = .explosiveBullet // Track active power-up type
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.activePowerUp = .unassigned // Reset power-up
        }
    }

    func activateTripleShot(duration: TimeInterval) {
        activePowerUp = .tripleShot
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.activePowerUp = .unassigned
        }
    }
}

protocol SpawnManagerDelegate: AnyObject {
    func didSpawnEnemy(_ enemy: Entity)
    func didSpawnBullet(_ bullet: BulletEntity)
    func didSpawnPlayerBullet(_ bullet: Entity)
    func didSpawnHealthPack(_ healthPack: HealthPackEntity)
    func didSpawnPowerUp(_ powerUp: PowerUpEntity)
}

extension SpawnManager {
    func spawnExplosionBullet(from position: CGPoint, to target: CGPoint) {
        guard let scene = scene as? GameScene else { return }
        let bullet = ExplosionBulletEntity(scene: scene, position: position, target: target)
        delegate?.didSpawnPlayerBullet(bullet)
    }

    func spawnTripleShot(from position: CGPoint) {
        guard let scene = scene as? GameScene else { return }

       // Define angles for bullets: center, slightly left, slightly right (in radians)
       let angles: [CGFloat] = [0, -0.2, 0.2] // Radians
       let bulletSpeed: CGFloat = 300 // Adjust speed as needed

       for angle in angles {
           // Calculate direction vector for each angle
           let dx = sin(angle) * bulletSpeed // X-axis offset
           let dy = cos(angle) * bulletSpeed // Y-axis offset (negative for downward)

           // Compute target position based on the direction vector
           let target = CGPoint(x: position.x + dx, y: position.y + dy)

           // Spawn bullet
           let bullet = SimpleBulletEntity(scene: scene, position: position, target: target)
           delegate?.didSpawnPlayerBullet(bullet)
       }
    }
}
