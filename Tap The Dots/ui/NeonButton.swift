import SpriteKit

class NeonButton: SKNode {
    private let buttonShape: SKShapeNode
    let labelNode: SKLabelNode

    init(text: String, size: CGSize, color: NSColor = .cyan) {
        // Create the button shape
        buttonShape = SKShapeNode(rectOf: size, cornerRadius: 10)
        buttonShape.fillColor = .clear           // Transparent fill
        buttonShape.strokeColor = color         // Neon color
        buttonShape.glowWidth = 3               // Glow effect
        buttonShape.lineWidth = 2               // Border thickness
        
        // Create the button label
        labelNode = SKLabelNode(text: text)
        labelNode.fontName = "Upheaval TT (BRK)" // Use your custom font
        labelNode.fontSize = 24
        labelNode.fontColor = color
        labelNode.verticalAlignmentMode = .center

        super.init()

        // Add shape and label to the button node
        addChild(buttonShape)
        addChild(labelNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addNeonPulse() {
        let pulseOut = SKAction.scale(to: 1.05, duration: 0.6)
        let pulseIn = SKAction.scale(to: 1.0, duration: 0.6)
        let pulseSequence = SKAction.sequence([pulseOut, pulseIn])
        buttonShape.run(SKAction.repeatForever(pulseSequence))
    }

    // Detect if the button is tapped
    override func contains(_ point: CGPoint) -> Bool {
        return buttonShape.contains(point)
    }
}
