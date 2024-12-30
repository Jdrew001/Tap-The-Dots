import SpriteKit

class SimpleBulletEntity: Entity {
    init(scene: SKScene, position: CGPoint, target: CGPoint) {
        super.init()

        // Render Component
        let bulletNode = SKShapeNode(circleOfRadius: 5)
        bulletNode.fillColor = .green
        bulletNode.strokeColor = .green
        bulletNode.lineWidth = 2
        bulletNode.glowWidth = 3
        bulletNode.blendMode = .add
        bulletNode.position = position
        bulletNode.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        bulletNode.physicsBody?.isDynamic = true
        bulletNode.physicsBody?.affectedByGravity = false
        bulletNode.physicsBody?.categoryBitMask = PhysicsCategory.PlayerBullet
        bulletNode.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        bulletNode.physicsBody?.collisionBitMask = PhysicsCategory.None
        bulletNode.physicsBody?.usesPreciseCollisionDetection = true
        
        scene.addChild(bulletNode)
        addComponent(RenderComponent(node: bulletNode))

        // Movement Component
        let direction = CGVector(dx: target.x - position.x, dy: target.y - position.y)
        let length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
        guard length > 0 else { return }
        let normalizedDirection = CGVector(dx: direction.dx / length, dy: direction.dy / length)
        let bulletSpeed: CGFloat = 500
        let velocity = CGVector(dx: normalizedDirection.dx * bulletSpeed,
                                 dy: normalizedDirection.dy * bulletSpeed)
        addComponent(MovementComponent(velocity: velocity, acceleration: 0, friction: 1.0))

        // Collision Component
        addComponent(CollisionComponent(size: CGSize(width: 10, height: 10)) { [weak self] _ in
            self?.destroy()
        })
    }
}
