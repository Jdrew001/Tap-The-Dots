import SpriteKit

class PlayerEntity: Entity {
    init(scene: SKScene, acceleration: CGFloat, friction: CGFloat) {
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
}
