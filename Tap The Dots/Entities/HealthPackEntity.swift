import SpriteKit

class HealthPackEntity: Entity {
    private let size: CGFloat = 40
    private let neonColor: SKColor = GameUtils.randomNeonColor()

    init(scene: SKScene) {
        super.init()

        // Render Component
        let circleNode = SKShapeNode(circleOfRadius: size / 2)
        circleNode.fillColor = .clear
        circleNode.strokeColor = .green
        circleNode.lineWidth = 8
        circleNode.glowWidth = 5
        circleNode.blendMode = .add
        circleNode.position = CGPoint(x: CGFloat.random(in: 0...scene.size.width), y: scene.size.height + size)
        
        // Add red cross in the middle
        let crossSize = size / 2.5
        let crossNode = SKShapeNode(rectOf: CGSize(width: crossSize, height: crossSize / 5))
        crossNode.fillColor = .green
        crossNode.strokeColor = .clear
        crossNode.zPosition = 1
        crossNode.position = CGPoint.zero // Center of the circle

        // Add vertical part of the cross
        let verticalNode = SKShapeNode(rectOf: CGSize(width: crossSize / 5, height: crossSize))
        verticalNode.fillColor = .green
        verticalNode.strokeColor = .clear
        verticalNode.zPosition = 1
        verticalNode.position = CGPoint.zero // Center of the circle
        
        // Add pulsing animation to the square
        let pulseUp = SKAction.scale(to: 1.2, duration: 0.5)
        let pulseDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
        circleNode.run(SKAction.repeatForever(pulseSequence))

        // Add cross to the circle node
        circleNode.addChild(crossNode)
        circleNode.addChild(verticalNode)

        scene.addChild(circleNode)
        addComponent(RenderComponent(node: circleNode))

        // Movement Component
        addComponent(MovementComponent(
            velocity: CGVector(dx: 0, dy: -120), // Smooth downward velocity
            acceleration: 0,
            friction: 1.0
        ))

        // Collision Component
        addComponent(CollisionComponent(size: CGSize(width: size, height: size), isCircular: true))
    }
}
