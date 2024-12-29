import SpriteKit

class TrailComponent: Component {
    var entity: Entity?

    private let neonColor: SKColor
    private let difficultyFactor: CGFloat
    private let size: CGSize

    init(color: SKColor, size: CGSize, difficultyFactor: CGFloat) {
        self.neonColor = color
        self.size = size
        self.difficultyFactor = difficultyFactor
    }

    func didAddToEntity() {
        guard let renderComponent = entity?.getComponent(ofType: RenderComponent.self),
              let scene = renderComponent.node.scene as? SKScene else {
            return
        }

        if let trail = SKEmitterNode(fileNamed: "TrailEffect.sks") {
            trail.targetNode = scene
            trail.zPosition = -1 // Render behind the entity
            trail.particleColor = neonColor
            trail.particleColorBlendFactor = 1.0

            // Align trail to the bottom center of the entity
            trail.position = CGPoint(x: 0, y: size.height / 2)

            // Adjust particle properties for smooth and dynamic trails
            trail.particleLifetime = 1.2
            trail.particleBirthRate = 100
            trail.particleSpeed = 150 * difficultyFactor
            trail.particleSpeedRange = 30
            trail.particleAlpha = 1.0
            trail.particleAlphaSpeed = -0.8
            trail.particleScale = size.width / 60.0 // Match entity size
            trail.particleScaleRange = size.width / 120.0
            trail.particleScaleSpeed = -0.05

            // Add the trail as a child to the entity's node
            renderComponent.node.addChild(trail)
        }
    }

    func willRemoveFromEntity() {
        guard let renderComponent = entity?.getComponent(ofType: RenderComponent.self) else { return }
        renderComponent.node.children.forEach { child in
            if let emitter = child as? SKEmitterNode {
                emitter.removeFromParent()
            }
        }
    }
}
