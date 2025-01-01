import SpriteKit

class EnemyExplodingComponent: Component {
    var entity: Entity?

    private let scene: GameScene
    private let position: CGPoint
    private let nodeColor: SKColor
    private let debrisCount: Int
    private let debrisSize: CGSize
    private let debrisSpeedRange: ClosedRange<CGFloat>

    init(scene: GameScene, position: CGPoint, nodeColor: SKColor, debrisCount: Int = 8, debrisSize: CGSize = CGSize(width: 6, height: 6), debrisSpeedRange: ClosedRange<CGFloat> = 100...400) {
        self.scene = scene
        self.position = position
        self.nodeColor = nodeColor
        self.debrisCount = debrisCount
        self.debrisSize = debrisSize
        self.debrisSpeedRange = debrisSpeedRange
    }

    func triggerExplosion() {
        guard let renderComponent = entity?.getComponent(ofType: RenderComponent.self) else {
            print("RenderComponent not found for entity.")
            return
        }
        
        // Get the exact position of the entity at the time of the explosion
        let explosionPosition = renderComponent.node.position
        
        // Gentle Flash Effect
        let flash = SKShapeNode(rect: CGRect(origin: .zero, size: scene.size))
        flash.fillColor = .white
        flash.alpha = 0.05 // Subtle brightness
        flash.zPosition = 10
        scene.addChild(flash)

        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()
        flash.run(SKAction.sequence([fadeOut, remove]))

        // Debris Effect
        for _ in 0..<debrisCount {
            let debris = SKShapeNode(rectOf: debrisSize)
            debris.fillColor = nodeColor
            debris.strokeColor = .clear
            debris.position = explosionPosition // Correctly set to the entity's current position
            scene.addChild(debris)

            let randomAngle = CGFloat.random(in: 0...CGFloat.pi * 2)
            let randomSpeed = CGFloat.random(in: debrisSpeedRange)
            let dx = cos(randomAngle) * randomSpeed
            let dy = sin(randomAngle) * randomSpeed
            let moveAction = SKAction.move(by: CGVector(dx: dx, dy: dy), duration: 1.0)
            let fadeOutAction = SKAction.fadeOut(withDuration: 1.0)
            let removeAction = SKAction.removeFromParent()
            let groupAction = SKAction.group([moveAction, fadeOutAction])
            debris.run(SKAction.sequence([groupAction, removeAction]))
        }

        // Remove Explosion Node
        renderComponent.node.removeFromParent()
    }
}
