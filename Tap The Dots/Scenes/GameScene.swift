import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties
    var player: PlayerEntity!
    var enemies: [Entity] = []
    var bullets: [BulletEntity] = []
    var playerBullets: [Entity] = []
    var healthPacks: [HealthPackEntity] = []
    var powerUps: [PowerUpEntity] = []
    var spawnManager: SpawnManager!
    var isShooting = false;
    private var healthBar: SKShapeNode!
    private var lastUpdateTime: TimeInterval = 0
    private var elapsedTime: TimeInterval = 0
    private var difficultyFactor: CGFloat = 1.0
    private var lastPhase = 0
    private var cameraNode: SKCameraNode!
    private var scrollingBackground: ScrollingBackground!
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupScene()
        setupPlayer()
        setupScoreComponent()
        setupSpawnManager()
        scheduleScoreUpdates()
        setupCamera()
        setupScrollingBackground()
        
        EventManager.shared.subscribe(event: "HighScoreUpdated") {
            self.showHighScoreNotification()
        }
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = calculateDeltaTime(currentTime: currentTime)
        elapsedTime += deltaTime
        updatePhase(deltaTime: deltaTime)
        let currentPhase = PhaseManager.shared.currentPhase
        let currentSettings = PhaseManager.shared.getSettings(for: currentPhase)
        spawnManager.update(deltaTime: deltaTime, currentPhase: currentPhase, currentSettings: currentSettings)
        updateEntities(deltaTime: deltaTime)
        scrollingBackground.update(deltaTime: deltaTime)
        handleCollisions()
        clampPlayerPosition()
        removeOffScreenEntities()
    }
    
    // MARK: - Input Handling
    override func keyDown(with event: NSEvent) {
        handlePlayerInput(event: event)
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 49: // Space bar key code
            isShooting = false // Stop shooting when space bar is released
        default:
            break
        }
    }
    
    // MARK: - Setup
    private func setupScene() {
        backgroundColor = .black
    }
    
    private func setupPlayer() {
        player = PlayerEntity(scene: self, acceleration: 450, friction: 0.98)
        player.addComponent(CollisionComponent(size: CGSize(width: 40, height: 40)) { [weak self] _ in
            self?.gameOver()
        })
        
        // Health Bar
        let barWidth: CGFloat = 100
        let barHeight: CGFloat = 10
        healthBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 5)
        healthBar.fillColor = .green
        healthBar.strokeColor = .clear
        healthBar.position = CGPoint(x: size.width / 2, y: size.height - 30)
        healthBar.zPosition = 1
        addChild(healthBar)
    }
    
    private func updateHealthBar() {
        let barWidth: CGFloat = 100
        let healthRatio = CGFloat(player.health) / CGFloat(player.maxHealth)
        healthBar.xScale = healthRatio
        
        if healthRatio > 0.5 {
            healthBar.fillColor = .green
        } else if healthRatio > 0.2 {
            healthBar.fillColor = .yellow
        } else {
            healthBar.fillColor = .red
        }
    }
    
    func showHealingEffect() {
        // Create a green border effect
        let overlay = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        overlay.fillColor = .clear
        overlay.strokeColor = .green
        overlay.lineWidth = 10
        overlay.alpha = 0.0
        overlay.zPosition = 100 // Render above everything else
        
        // Add the overlay to the scene
        addChild(overlay)
        
        // Animate the effect: fade in, hold, and fade out
        let fadeIn = SKAction.fadeAlpha(to: 0.6, duration: 0.2)
        let hold = SKAction.wait(forDuration: 0.3)
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.5)
        let remove = SKAction.removeFromParent()
        overlay.run(SKAction.sequence([fadeIn, hold, fadeOut, remove]))
    }
    
    private func setupScoreComponent() {
        let scoreComponent = ScoreComponent(position: CGPoint(x: 20, y: size.height - 20))
        scoreComponent.attachTo(scene: self)
    }
    
    private func setupSpawnManager() {
        spawnManager = SpawnManager(scene: self, difficultyFactor: difficultyFactor)
        spawnManager.delegate = self
    }
    
    private func scheduleScoreUpdates() {
        let incrementAction = SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.run { ScoreManager.shared.increment(by: 1) }
        ])
        run(SKAction.repeatForever(incrementAction))
    }
    
    // MARK: - Phase Management --> TODO: Move this to manager and add update function to update method in this class
    private func updatePhase(deltaTime: TimeInterval) {
        PhaseManager.shared.updatePhase(deltaTime: deltaTime)
        let currentPhase = PhaseManager.shared.currentPhase
        
        if currentPhase != lastPhase {
            displayPhaseNotification(phase: currentPhase)
            lastPhase = currentPhase
            spawnManager.resetSpawnDelay()
        }
    }
    
    private func setupCamera() {
        cameraNode = SKCameraNode()
        self.camera = cameraNode
        addChild(cameraNode)
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    // MARK: - Entity Updates
    private func updateEntities(deltaTime: TimeInterval) {
        player.update(deltaTime: deltaTime)
        
        for enemy in enemies {
            enemy.update(deltaTime: deltaTime)
        }
        
        for bullet in bullets {
            bullet.update(deltaTime: deltaTime)
        }
        
        for bullet in playerBullets {
            bullet.update(deltaTime: deltaTime)
        }
        
        for healthPack in healthPacks {
            healthPack.update(deltaTime: deltaTime)
        }
        
        for powerUp in powerUps {
            powerUp.update(deltaTime: deltaTime)
        }
    }
    
    private func removeOffScreenEntities() {
        enemies.removeAll { enemy in
            let isOffScreen = isNodeOffScreen(enemy)
            if isOffScreen {
                enemy.getComponent(ofType: RenderComponent.self)?.node.removeFromParent()
                enemy.destroy()
            }
            return isOffScreen
        }
        
        bullets.removeAll { bullet in
            let isOffScreen = isNodeOffScreen(bullet)
            if isOffScreen {
                bullet.getComponent(ofType: RenderComponent.self)?.node.removeFromParent()
                bullet.destroy()
            }
            return isOffScreen
        }
        
        playerBullets.removeAll { bullet in
            let isOffScreen = isNodeOffScreen(bullet)
            if isOffScreen {
                bullet.getComponent(ofType: RenderComponent.self)?.node.removeFromParent()
                bullet.destroy()
            }
            return isOffScreen
        }
        
        healthPacks.removeAll { healthPack in
            let isOffScreen = isNodeOffScreen(healthPack)
            if isOffScreen {
                healthPack.getComponent(ofType: RenderComponent.self)?.node.removeFromParent()
                healthPack.destroy()
            }
            return isOffScreen
        }
    }
    
    private func isNodeOffScreen(_ entity: Entity) -> Bool {
        guard let renderComponent = entity.getComponent(ofType: RenderComponent.self) else {
            return false
        }
        
        let node = renderComponent.node
        let position = node.position
        let frame = node.frame
        
        let minX: CGFloat = 0
        let maxX: CGFloat = size.width
        let minY: CGFloat = -2500
        let maxY: CGFloat = size.height
        
        return (position.x + frame.width < minX ||
                position.x - frame.width > maxX ||
                position.y + frame.height < minY ||
                position.y - frame.height > maxY)
    }
    
    // MARK: - Utility Methods
    private func calculateDeltaTime(currentTime: TimeInterval) -> TimeInterval {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        return deltaTime
    }
    
    private func clampPlayerPosition() {
        guard let renderComponent = player.getComponent(ofType: RenderComponent.self) else { return }
        let node = renderComponent.node
        let minY = node.frame.height / 2
        let maxY = size.height - node.frame.height / 2
        node.position.y = max(min(node.position.y, maxY), minY)
    }
    
    private func handleCollisions() {
        guard let playerCollision = player.getComponent(ofType: CollisionComponent.self) else { return }

        // Handle collisions with enemies
        for enemy in enemies {
            if let enemyCollision = enemy.getComponent(ofType: CollisionComponent.self),
               playerCollision.checkCollision(with: enemyCollision) {
                player.takeDamage()
                updateHealthBar()
                if !player.isAlive() {
                    gameOver()
                }
                return
            }
        }

        // Handle collisions with bullets
        for bullet in bullets {
            if let bulletCollision = bullet.getComponent(ofType: CollisionComponent.self),
               playerCollision.checkCollision(with: bulletCollision) {
                player.takeDamage()
                updateHealthBar()
                if !player.isAlive() {
                    gameOver()
                }
                return
            }
        }

        // Handle collisions between player bullets and enemies
        for bullet in playerBullets {
            if let bulletCollision = bullet.getComponent(ofType: CollisionComponent.self) {
                for enemy in enemies {
                    if let enemyCollision = enemy.getComponent(ofType: CollisionComponent.self),
                       bulletCollision.checkCollision(with: enemyCollision) {
                        
                        // Check if the bullet is an explosion bullet
                        if let explosionComponent = bullet.getComponent(ofType: ExplosionComponent.self) {
                            // Trigger the bullet's explosion only
                            explosionComponent.triggerExplosion()
                            bullet.destroy()
                            enemy.destroy()
                            return // Skip enemy explosion
                        }
                        
                        // Otherwise, trigger the enemy's explosion
                        if let explodingComponent = enemy.getComponent(ofType: EnemyExplodingComponent.self) {
                            explodingComponent.triggerExplosion()
                        }
                        enemy.destroy() // Remove enemy after explosion effect
                        bullet.destroy()
                    }
                }
            }
        }

        // Handle collisions with health packs
        for healthPack in healthPacks {
            if let healthPackCollision = healthPack.getComponent(ofType: CollisionComponent.self),
               playerCollision.checkCollision(with: healthPackCollision) {
                player.heal() // Heal the player
                updateHealthBar()
                removeHealthPack(healthPack) // Remove the collected health pack
                return
            }
        }

        // Handle collisions with power-ups
        for powerUp in powerUps {
            if let powerUpCollision = powerUp.getComponent(ofType: CollisionComponent.self),
               playerCollision.checkCollision(with: powerUpCollision) {
                // Delegate the power-up effect to the player
                player.applyPowerUp(powerUp)

                // Remove the collected power-up
                powerUp.getComponent(ofType: RenderComponent.self)?.node.removeFromParent()
                powerUps.removeAll { $0 === powerUp }
            }
        }
    }
    private func removeHealthPack(_ healthPack: HealthPackEntity) {
        if let renderComponent = healthPack.getComponent(ofType: RenderComponent.self) {
            renderComponent.node.removeFromParent()
        }
        healthPacks.removeAll { $0 === healthPack }
    }
    
    private func displayPhaseNotification(phase: Int) {
        let label = SKLabelNode(text: "Phase \(phase)")
        label.fontName = "Upheaval TT (BRK)"
        label.fontSize = 40
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.alpha = 0
        addChild(label)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        label.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }
    
    
    private func showHighScoreNotification() {
        let label = SKLabelNode(text: "New High Score!")
        label.fontName = "Upheaval TT (BRK)"
        label.fontSize = 40
        label.fontColor = .yellow
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.alpha = 0
        addChild(label)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 1.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        label.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }
    
    private func handlePlayerInput(event: NSEvent) {
        guard let movementComponent = player.getComponent(ofType: MovementComponent.self) else { return }
        
        switch event.keyCode {
        case 0: movementComponent.applyInput(direction: CGVector(dx: -1, dy: 0)) // 'A' Key
        case 2: movementComponent.applyInput(direction: CGVector(dx: 1, dy: 0))  // 'D' Key
        case 1: movementComponent.applyInput(direction: CGVector(dx: 0, dy: -1)) // 'S' Key
        case 13: movementComponent.applyInput(direction: CGVector(dx: 0, dy: 1)) // 'W' Key
        case 49: if !isShooting { // Start shooting if not already
            isShooting = true
            startContinuousShooting()
        }
        default: break
        }
    }
    
    private func startContinuousShooting() {
        guard isShooting else { return } // Exit if shooting is stopped

        player.shoot(using: spawnManager) // Trigger a single shot

        // Schedule the next shot
        DispatchQueue.main.asyncAfter(deadline: .now() + player.shootCooldown) { [weak self] in
            self?.startContinuousShooting()
        }
    }
    
    private func setupScrollingBackground() {
        scrollingBackground = ScrollingBackground(imageName: "background-black", scrollSpeed: 50, sceneSize: size)
        scrollingBackground.zPosition = -1
        addChild(scrollingBackground)
    }
    
    func gameOver() {
        // Notify event listeners that the game is over
        EventManager.shared.notify(event: "GameOver")
        
        // Update high score if the current score is higher
        ScoreManager.shared.updateHighScoreIfNeeded()
        
        // Retrieve the scores for display
        let currentScore = ScoreManager.shared.getScore()
        let highScore = ScoreManager.shared.highScore
        
        // Transition to the GameOverScene
        let gameOverScene = GameOverScene(size: size, score: currentScore, highScore: highScore)
        gameOverScene.scaleMode = .aspectFill
        view?.presentScene(gameOverScene, transition: SKTransition.fade(withDuration: 1.0))
        
        // Reset game state
        ScoreManager.shared.reset()
        PhaseManager.shared.reset()
    }
}

extension GameScene: SpawnManagerDelegate {
    func didSpawnPlayerBullet(_ bullet: Entity) {
        playerBullets.append(bullet)
    }
    
    func didSpawnEnemy(_ enemy: Entity) {
        enemies.append(enemy)
    }
    func didSpawnBullet(_ bullet: BulletEntity) {
        bullets.append(bullet)
    }
    func didSpawnHealthPack(_ healthPack: HealthPackEntity) {
        healthPacks.append(healthPack)
    }
    func didSpawnPowerUp(_ powerUp: PowerUpEntity) {
        powerUps.append(powerUp)
    }
}

extension GameScene {
    func shakeScreen(duration: TimeInterval, intensity: CGFloat) {
        guard let cameraNode = cameraNode else { return }

        // Create a shake action
        let shakeAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let randomX = CGFloat.random(in: -intensity...intensity)
            let randomY = CGFloat.random(in: -intensity...intensity)
            node.position = CGPoint(x: self.size.width / 2 + randomX, y: self.size.height / 2 + randomY)
        }

        // Reset the camera position after shaking
        let resetPosition = SKAction.run { [weak self] in
            self?.cameraNode.position = CGPoint(x: self!.size.width / 2, y: self!.size.height / 2)
        }

        // Run the shake followed by resetting the position
        cameraNode.run(SKAction.sequence([shakeAction, resetPosition]))
    }
}

extension GameScene {
    func activateTimeSlow(duration: TimeInterval) {
        let slowFactor: CGFloat = 0.75 // Slow down by 50%

        // Slow down enemy, bullet, and projectile movements
        for enemy in enemies {
            if let movementComponent = enemy.getComponent(ofType: MovementComponent.self) {
                movementComponent.velocity.dx *= slowFactor
                movementComponent.velocity.dy *= slowFactor
            }
        }

        for bullet in bullets {
            if let movementComponent = bullet.getComponent(ofType: MovementComponent.self) {
                movementComponent.velocity.dx *= slowFactor
                movementComponent.velocity.dy *= slowFactor
            }
        }

        for playerBullet in playerBullets {
            if let movementComponent = playerBullet.getComponent(ofType: MovementComponent.self) {
                movementComponent.velocity.dx *= slowFactor
                movementComponent.velocity.dy *= slowFactor
            }
        }

        // Add a visual overlay to indicate time is slowed
        let overlay = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        overlay.fillColor = .black
        overlay.alpha = 0.4
        overlay.zPosition = 100 // Render above everything else
        addChild(overlay)

        // Restore normal speed after the duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self = self else { return }

            for enemy in self.enemies {
                if let movementComponent = enemy.getComponent(ofType: MovementComponent.self) {
                    movementComponent.velocity.dx /= slowFactor
                    movementComponent.velocity.dy /= slowFactor
                }
            }

            for bullet in self.bullets {
                if let movementComponent = bullet.getComponent(ofType: MovementComponent.self) {
                    movementComponent.velocity.dx /= slowFactor
                    movementComponent.velocity.dy /= slowFactor
                }
            }

            for playerBullet in self.playerBullets {
                if let movementComponent = playerBullet.getComponent(ofType: MovementComponent.self) {
                    movementComponent.velocity.dx /= slowFactor
                    movementComponent.velocity.dy /= slowFactor
                }
            }

            overlay.removeFromParent()
        }
    }
}
