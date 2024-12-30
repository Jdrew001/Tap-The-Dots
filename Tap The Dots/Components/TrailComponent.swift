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

            // Adjust particle properties for smaller, smoother trails
            trail.particleLifetime = 5 // Shorter lifetime for smaller trails
            trail.particleBirthRate = 50 // Fewer particles for a lighter effect
            trail.particleSpeed = 100 * difficultyFactor // Slower particle speed
            trail.particleSpeedRange = 20
            trail.particleAlpha = 1.0
            trail.particleAlphaSpeed = -0.5
            trail.particleScale = size.width / 120.0 // Reduced particle size
            trail.particleScaleRange = size.width / 240.0
            trail.particleScaleSpeed = -0.02

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
