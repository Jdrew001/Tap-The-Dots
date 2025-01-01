import SpriteKit

class BulletEntity: Entity {
    private var lifespan: TimeInterval = 5.0 // Bullet lifespan in seconds
    private var initialVelocity: CGVector? // Store the initial velocity

    init(scene: SKScene, position: CGPoint, target: CGPoint) {
        super.init()

        // Render Component
        let bulletNode = SKShapeNode(circleOfRadius: 5)
        bulletNode.fillColor = .red
        bulletNode.strokeColor = .red
        bulletNode.lineWidth = 2
        bulletNode.glowWidth = 3
        bulletNode.blendMode = .add
        bulletNode.position = position

        // Physics Body
        bulletNode.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        bulletNode.physicsBody?.isDynamic = true
        bulletNode.physicsBody?.affectedByGravity = false
        bulletNode.physicsBody?.categoryBitMask = PhysicsCategory.Bullet
        bulletNode.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        bulletNode.physicsBody?.collisionBitMask = PhysicsCategory.None
        bulletNode.physicsBody?.usesPreciseCollisionDetection = true

        scene.addChild(bulletNode)
        addComponent(RenderComponent(node: bulletNode))

        // Calculate Direction and Velocity
        let direction = CGVector(dx: target.x - position.x, dy: target.y - position.y)
        let length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
        guard length > 0 else { return }
        let normalizedDirection = CGVector(dx: direction.dx / length, dy: direction.dy / length)
        let bulletSpeed: CGFloat = 300
        let velocity = CGVector(dx: normalizedDirection.dx * bulletSpeed,
                                 dy: normalizedDirection.dy * bulletSpeed)

        // Store initial velocity
        initialVelocity = velocity

        // Movement Component
        addComponent(MovementComponent(velocity: velocity, acceleration: 0, friction: 1.0))

        // Collision Component
        addComponent(CollisionComponent(size: CGSize(width: 10, height: 10)) { [weak self] _ in
            self?.destroy()
        })
    }
    
    override func update(deltaTime: TimeInterval) {
        // Decrease lifespan
        lifespan -= deltaTime
        if lifespan <= 0 {
            destroy()
            return
        }

        // Enforce movement
        if let movementComponent = getComponent(ofType: MovementComponent.self) {
            if movementComponent.velocity.dx == 0 && movementComponent.velocity.dy == 0,
               let velocity = initialVelocity {
                movementComponent.velocity = velocity // Reapply initial velocity
            }
            movementComponent.update(deltaTime: deltaTime)
        }
    }
}
