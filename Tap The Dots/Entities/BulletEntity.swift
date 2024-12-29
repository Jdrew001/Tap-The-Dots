import SpriteKit

class BulletEntity: Entity {
    init(scene: SKScene, position: CGPoint, target: CGPoint) {
        super.init()

        // Render Component
        let bulletNode = SKShapeNode(circleOfRadius: 2)
        bulletNode.fillColor = .clear
        bulletNode.strokeColor = .red
        bulletNode.lineWidth = 4
        bulletNode.glowWidth = 5
        bulletNode.blendMode = .add
        bulletNode.position = position
        
        // Add pulsing animation to the square
        let pulseUp = SKAction.scale(to: 1.2, duration: 0.5)
        let pulseDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
        bulletNode.run(SKAction.repeatForever(pulseSequence))
        
        scene.addChild(bulletNode)
        addComponent(RenderComponent(node: bulletNode))

        // Movement Component
        let direction = CGVector(dx: target.x - position.x, dy: target.y - position.y)
        let length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
        guard length > 0 else { return }
        let normalizedDirection = CGVector(dx: direction.dx / length, dy: direction.dy / length)
        let bulletSpeed: CGFloat = 300
        let velocity = CGVector(dx: normalizedDirection.dx * bulletSpeed,
                                 dy: normalizedDirection.dy * bulletSpeed)
        addComponent(MovementComponent(velocity: velocity, acceleration: 0, friction: 1.0))

        // Collision Component
        addComponent(CollisionComponent(size: CGSize(width: 10, height: 10)) { [weak self] _ in
            self?.destroy()
        })
    }

    func destroy() {
        guard let renderComponent = getComponent(ofType: RenderComponent.self) else { return }
        renderComponent.node.removeFromParent()
    }
}
