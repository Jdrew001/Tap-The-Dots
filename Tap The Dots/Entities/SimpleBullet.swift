import SpriteKit

class BulletEntity: Entity {
    init(scene: SKScene, position: CGPoint, target: CGPoint) {
        super.init()

        // Render Component
        let bulletNode = SKShapeNode(circleOfRadius: 5)
        bulletNode.fillColor = .yellow
        bulletNode.strokeColor = .clear
        bulletNode.position = position
        bulletNode.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        bulletNode.physicsBody?.isDynamic = true
        bulletNode.physicsBody?.affectedByGravity = false
        bulletNode.physicsBody?.categoryBitMask = PhysicsCategory.Bullet
        bulletNode.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        bulletNode.physicsBody?.collisionBitMask = PhysicsCategory.None
        bulletNode.physicsBody?.usesPreciseCollisionDetection = true
        scene.addChild(bulletNode)
        addComponent(RenderComponent(node: bulletNode))

        // Movement Component
        addComponent(MovementComponent(
            velocity: CGVector(dx: 0, dy: 400),
            acceleration: 0,
            friction: 1.0
        ))

        // Collision Component
        addComponent(CollisionComponent(size: CGSize(width: 10, height: 10)) { [weak self] entity in
            if entity is EnemyEntity {
                entity.destroy() // Destroy the enemy
                self?.destroy()  // Destroy the bullet
            }
        })
    }

    func destroy() {
        guard let renderComponent = getComponent(ofType: RenderComponent.self) else { return }
        renderComponent.node.removeFromParent()
    }
}
