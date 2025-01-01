import SpriteKit

class EnemyEntity: Entity {
    init(scene: SKScene, type: String, difficultyFactor: CGFloat) {
        super.init()

        let enemyNode: SKShapeNode
        let size: CGSize
        let color: NSColor

        // Configure enemy appearance based on type
        switch type {
        case "Shooter":
            color = .red
            size = CGSize(width: 30, height: 30)
            enemyNode = SKShapeNode(rectOf: size, cornerRadius: 5)
            enemyNode.fillColor = color
            addComponent(ShooterComponent()) // Add shooter behavior
        case "FastMover":
            color = .yellow
            size = CGSize(width: 20, height: 20)
            enemyNode = SKShapeNode(circleOfRadius: 10)
            enemyNode.fillColor = color
        default:
            color = .gray
            size = CGSize(width: 25, height: 25)
            enemyNode = SKShapeNode(rectOf: size, cornerRadius: 3)
            enemyNode.fillColor = color
        }

        // Position enemy at the top of the screen
        enemyNode.position = CGPoint(
            x: CGFloat.random(in: 0...scene.size.width),
            y: scene.size.height + size.height
        )
        scene.addChild(enemyNode)

        // Add components
        addComponent(RenderComponent(node: enemyNode))
        addComponent(MovementComponent(
            velocity: CGVector(dx: 0, dy: -200 * difficultyFactor), // Adjust speed dynamically
            acceleration: 0,
            friction: 1.0
        ))
        addComponent(CollisionComponent(size: size))
        addComponent(CollisionComponent(size: CGSize(width: size.width, height: size.height)) { [weak self] entity in
            if entity is BulletEntity {
                self?.destroy() // Destroy the enemy
            }
        })
        // Add the explosion component
        addComponent(EnemyExplodingComponent(
            scene: scene as! GameScene,
            position: enemyNode.position, // Use the current position of the node
            nodeColor: color
        ))
    }
}
