import SpriteKit

class ScoreComponent: Component {
    var entity: Entity?

    private let labelNode: SKLabelNode

    init(fontSize: CGFloat = 24, fontColor: SKColor = .white, position: CGPoint = CGPoint(x: 20, y: 20)) {
        // Initialize the label node
        labelNode = SKLabelNode(text: "Score: 0")
        labelNode.fontSize = fontSize
        labelNode.fontColor = fontColor
        labelNode.fontName = "Upheaval TT (BRK)"
        labelNode.horizontalAlignmentMode = .left
        labelNode.verticalAlignmentMode = .top
        labelNode.position = position
    }

    func attachTo(scene: SKScene) {
        scene.addChild(labelNode)

        // Subscribe to ScoreManager updates
        ScoreManager.shared.subscribe { newScore in
            self.updateScore(to: newScore)
        }
    }

    private func updateScore(to newScore: Int) {

        DispatchQueue.main.async {
            self.labelNode.text = "Score: \(newScore)"
        }
    }

    func update(deltaTime: TimeInterval) {
        // No frame-based updates needed for this component
    }
}
