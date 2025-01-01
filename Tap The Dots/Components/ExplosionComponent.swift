import SpriteKit

class ExplosionComponent: Component {
    var entity: Entity?
    private let scene: GameScene
    private let radius: CGFloat
    private let damageRadius: CGFloat
    private let position: CGPoint

    init(scene: GameScene, radius: CGFloat, damageRadius: CGFloat, position: CGPoint) {
        self.scene = scene
        self.radius = radius
        self.damageRadius = damageRadius
        self.position = position
    }

    func triggerExplosion() {
        guard let explosionNode = entity?.getComponent(ofType: RenderComponent.self)?.node else {
            print("Explosion node not found")
            return
        }

        // Flash Effect
        let flash = SKShapeNode(rect: CGRect(origin: .zero, size: scene.size))
        flash.fillColor = .white
        flash.alpha = 0.1
        flash.zPosition = 10
        scene.addChild(flash)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        flash.run(SKAction.sequence([fadeOut, remove]))

        // Debris Effect
        for _ in 0..<10 {
            let debris = SKShapeNode(circleOfRadius: 3)
            debris.fillColor = .gray
            debris.position = explosionNode.position // Use the explosion node's position
            scene.addChild(debris)
            
            let randomAngle = CGFloat.random(in: 0...CGFloat.pi * 2)
            let randomSpeed: CGFloat = CGFloat.random(in: 100...500)
            let dx = cos(randomAngle) * randomSpeed
            let dy = sin(randomAngle) * randomSpeed
            let move = SKAction.move(by: CGVector(dx: dx, dy: dy), duration: 1.0)
            let fadeOut = SKAction.fadeOut(withDuration: 2.0)
            let remove = SKAction.removeFromParent()
            debris.run(SKAction.sequence([SKAction.group([move, fadeOut]), remove]))
        }

        // Damage Nearby Enemies
        for enemy in scene.enemies {
            if let renderComponent = enemy.getComponent(ofType: RenderComponent.self) {
                let distance = renderComponent.node.position.distance(to: explosionNode.position)
                if distance <= damageRadius {
                    enemy.destroy()
                }
            }
        }

        // Remove Explosion Node
        explosionNode.removeFromParent()
    }
}
