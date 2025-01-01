import SpriteKit

class PlayerEntity: Entity {
    var health: Int
    let maxHealth: Int
    var canShoot: Bool = true
    let shootCooldown: TimeInterval = 0.3
    private var explosiveRoundTimer: TimeInterval = 0
    private var isUsingTripleShot = false
    private var isInvincible: Bool = false
    private var isShooting: Bool = false
    private var shootTimer: Timer? // Timer for continuous shooting

    init(scene: SKScene, acceleration: CGFloat, friction: CGFloat, maxHealth: Int = 3) {
        self.health = maxHealth
        self.maxHealth = maxHealth
        super.init()
        
        // Calculate the size of the triangle
        let radius: CGFloat = 20
        let base = radius
        let height = radius

        // Create the triangle path
        let trianglePath = CGMutablePath()
        trianglePath.move(to: CGPoint(x: 0, y: height)) // Top point
        trianglePath.addLine(to: CGPoint(x: -base / 2, y: 0)) // Bottom left
        trianglePath.addLine(to: CGPoint(x: base / 2, y: 0))  // Bottom right
        trianglePath.closeSubpath()

        // Create the triangle shape node
        let playerNode = SKShapeNode(path: trianglePath)
        playerNode.fillColor = .clear // Transparent center for neon effect
        playerNode.strokeColor = .white // Neon blue border
        playerNode.glowWidth = 5       // Glow effect
        playerNode.lineWidth = 8       // Border thickness
        playerNode.blendMode = .add    // Additive blend for glowing effect

        // Position the triangle in the scene
        playerNode.position = CGPoint(x: scene.size.width / 2, y: 50)
        scene.addChild(playerNode)
        
        // Attach the render component to the player
        addComponent(RenderComponent(node: playerNode))
        
        // Create and add the movement component
        addComponent(MovementComponent(acceleration: acceleration, friction: friction))
        addComponent(CollisionComponent(size: CGSize(width: 40, height: 40)))
    }
    
    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)
        explosiveRoundTimer = max(0, explosiveRoundTimer - deltaTime)
    }
    
    func takeDamage() {
        guard !isInvincible else { return } // Ignore damage if invincible
        health -= 1
        if let scene = getComponent(ofType: RenderComponent.self)?.node.scene as? GameScene {
            scene.shakeScreen(duration: 0.5, intensity: 15)
        }
        flashPlayer()
    }
    
    func heal(by amount: Int = 1) {
        health = min(health + amount, maxHealth) // Cap health at maxHealth
        if let scene = getComponent(ofType: RenderComponent.self)?.node.scene as? GameScene {
            scene.showHealingEffect()
        }
    }

    func isAlive() -> Bool {
        return health > 0
    }
    
    func applyPowerUp(_ powerUp: PowerUpEntity) {
        switch powerUp.type {
        case .explosiveBullet:
            activateExplosiveBullets()
        case .tripleShot:
            activateTripleShot()
        case .shield:
            activateShield(duration: 10) // Shield lasts for 10 seconds
        case .slowTime:
            if let scene = getComponent(ofType: RenderComponent.self)?.node.scene as? GameScene {
                scene.activateTimeSlow(duration: 10) // Slow time for 5 seconds
            }
        default:
            break
        }
    }
    
    func startShooting(using spawnManager: SpawnManager) {
        guard !isShooting else { return }
        isShooting = true
        
        // Start the shooting timer
        shootTimer = Timer.scheduledTimer(withTimeInterval: shootCooldown, repeats: true) { [weak self] _ in
            self?.shoot(using: spawnManager)
        }
    }

    func stopShooting() {
        isShooting = false
        shootTimer?.invalidate()
        shootTimer = nil
    }

    func shoot(using spawnManager: SpawnManager) {
        guard canShoot else { return } // Prevent shooting during cooldown

        guard let renderComponent = getComponent(ofType: RenderComponent.self),
              let scene = renderComponent.node.scene else { return }

        let position = renderComponent.node.position
        let target = CGPoint(x: position.x, y: scene.size.height)

        // Spawn normal bullet
        spawnManager.spawnPlayerBullet(from: position, to: target)

        // Spawn power-up bullets if active
        if explosiveRoundTimer > 0 {
            spawnManager.spawnExplosionBullet(from: position, to: target)
        }

        if isUsingTripleShot {
            spawnManager.spawnTripleShot(from: position)
        }
    }

    func activateExplosiveBullets() {
        explosiveRoundTimer = 20.0 // Active for 20 seconds
    }

    func activateTripleShot() {
        isUsingTripleShot = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.isUsingTripleShot = false // Disable after 10 seconds
        }
    }

    func activateShield(duration: TimeInterval) {
        // Enable invincibility for a duration
        isInvincible = true

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isInvincible = false
        }
    }
    
    private func flashPlayer() {
        guard let renderComponent = getComponent(ofType: RenderComponent.self) else { return }
        let node = renderComponent.node

        // Set the invincible state before starting the flash effect
        isInvincible = true

        let flashAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.3),
            SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        ])
        
        // Run the flash effect and reset invincibility at the end
        let invincibilitySequence = SKAction.sequence([
            SKAction.repeat(flashAction, count: 3),
            SKAction.run { [weak self] in
                self?.isInvincible = false
            }
        ])
        node.run(invincibilitySequence)
    }
}
