import SpriteKit

class ShootingEnemyEntity: Entity {
    init(scene: SKScene, difficultyFactor: CGFloat) {
        super.init()
        let size = CGSize(width: 30, height: 30)
        let neonColor = GameUtils.randomNeonColor()

        // Render Component
        let shooterNode = SKShapeNode(rectOf: size, cornerRadius: 5)
        shooterNode.fillColor = .red // Transparent background
        shooterNode.strokeColor = neonColor // Neon color
        shooterNode.lineWidth = 8      // Width of the neon border
        shooterNode.glowWidth = 5      // Glow effect
        shooterNode.blendMode = .add   // Additive blend for neon effect
        shooterNode.position = CGPoint(
            x: CGFloat.random(in: 0...scene.size.width),
            y: scene.size.height + 30
        )
        scene.addChild(shooterNode)
        addComponent(RenderComponent(node: shooterNode))

        // Movement Component
        addComponent(MovementComponent(velocity: CGVector(dx: 0, dy: -200 * difficultyFactor),
                                        acceleration: 0,
                                        friction: 1.0))
        
        addComponent(ShooterComponent())
        addComponent(CollisionComponent(size: CGSize(width: 30, height: 30)) { [weak self] _ in
            self?.destroy()
        })
        addComponent(TrailComponent(color: neonColor, size: size, difficultyFactor: difficultyFactor))
    }

    func destroy() {
        guard let renderComponent = getComponent(ofType: RenderComponent.self) else { return }
        renderComponent.node.removeFromParent()
    }
}
