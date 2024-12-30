import SpriteKit

class ObstacleEntity: Entity {
    init(scene: SKScene, difficultyFactor: CGFloat, size: CGSize) {
        super.init()
        let neonColor = GameUtils.randomNeonColor()

       // Create the neon square
       let obstacleNode = SKShapeNode(rectOf: size, cornerRadius: size.width / 10)
       obstacleNode.fillColor = .clear // Transparent background
       obstacleNode.strokeColor = neonColor // Neon color
       obstacleNode.lineWidth = 8      // Width of the neon border
       obstacleNode.glowWidth = 5      // Glow effect
       obstacleNode.blendMode = .add   // Additive blend for neon effect

       // Add pulsing animation to the square
       let pulseUp = SKAction.scale(to: 1.2, duration: 0.5)
       let pulseDown = SKAction.scale(to: 1.0, duration: 0.5)
       let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
       obstacleNode.run(SKAction.repeatForever(pulseSequence))

        obstacleNode.position = CGPoint(
            x: CGFloat.random(in: 0...scene.size.width), // Random horizontal position across the screen
            y: scene.frame.maxY + (size.height / 2) // Fully outside the visible top edge
        )
        scene.addChild(obstacleNode)
       addComponent(RenderComponent(node: obstacleNode))

       // Add MovementComponent
       addComponent(MovementComponent(velocity: CGVector(dx: 0, dy: -200 * difficultyFactor),
                                       acceleration: 0,
                                       friction: 1.0))
        
        addComponent(CollisionComponent(size: size) { [weak self] _ in
            self?.destroy()
        })

        addComponent(TrailComponent(color: neonColor, size: size, difficultyFactor: difficultyFactor))
    }
}
