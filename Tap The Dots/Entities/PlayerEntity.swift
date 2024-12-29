import SpriteKit

class PlayerEntity: Entity {
    var health: Int
    let maxHealth: Int
    private var isInvincible: Bool = false
    
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
    }
    
    func takeDamage() {
        guard !isInvincible else { return } // Ignore damage if invincible
        health -= 1
        if let scene = getComponent(ofType: RenderComponent.self)?.node.scene as? GameScene {
            scene.shakeScreen(duration: 0.5, intensity: 15)
        }
        flashPlayer()
    }

    func isAlive() -> Bool {
        return health > 0
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
