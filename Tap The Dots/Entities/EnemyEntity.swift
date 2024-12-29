import SpriteKit

class EnemyEntity: Entity {
    init(scene: SKScene, type: String, difficultyFactor: CGFloat) {
        super.init()

        let enemyNode: SKShapeNode
        let size: CGSize

        // Configure enemy appearance based on type
        switch type {
        case "Shooter":
            size = CGSize(width: 30, height: 30)
            enemyNode = SKShapeNode(rectOf: size, cornerRadius: 5)
            enemyNode.fillColor = .red
            addComponent(ShooterComponent()) // Add shooter behavior
        case "FastMover":
            size = CGSize(width: 20, height: 20)
            enemyNode = SKShapeNode(circleOfRadius: 10)
            enemyNode.fillColor = .yellow
        default:
            size = CGSize(width: 25, height: 25)
            enemyNode = SKShapeNode(rectOf: size, cornerRadius: 3)
            enemyNode.fillColor = .gray
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
    }
}
