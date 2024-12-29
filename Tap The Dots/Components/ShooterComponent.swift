import SpriteKit

class ShooterComponent: Component {
    var entity: Entity?
    private var shootTimer: TimeInterval = 0
    private var bullets: [BulletEntity] = []

    func update(deltaTime: TimeInterval) {
        shootTimer += deltaTime
        if shootTimer > 1.5 { // Shoot every 1.5 seconds
            shoot()
            shootTimer = 0
        }

        // Update bullets and remove off-screen ones
        bullets.removeAll { bullet in
            guard let renderComponent = bullet.getComponent(ofType: RenderComponent.self),
                  let node = renderComponent.node.parent else { return false }

            // Remove bullets that move off-screen
            if !node.frame.intersects(renderComponent.node.frame) {
                renderComponent.node.removeFromParent()
                return true
            }
            return false
        }

        // Update each bullet
        bullets.forEach { $0.update(deltaTime: deltaTime) }
    }

    private func shoot() {
        guard let renderComponent = entity?.getComponent(ofType: RenderComponent.self),
              let scene = renderComponent.node.scene else { return }

        // Check if the shooter is off-screen
        if isOffScreen(node: renderComponent.node, in: scene) {
            print("Shooter is off-screen, skipping shoot")
            return
        }

        // Get the target position (player position)
        guard let playerRenderComponent = (scene as? GameScene)?.player.getComponent(ofType: RenderComponent.self) else { return }
        let targetPosition = playerRenderComponent.node.position

        // Create a new bullet
        let bullet = BulletEntity(scene: scene,
                                  position: renderComponent.node.position,
                                  target: targetPosition)

        // Add bullet to the scene and track it
//        if let renderComponent = bullet.getComponent(ofType: RenderComponent.self) {
//            scene.addChild(renderComponent.node)
//        }
        bullets.append(bullet)
    }

    private func isOffScreen(node: SKNode, in scene: SKScene) -> Bool {
        let position = node.position
        let frame = scene.frame

        return position.x + node.frame.width < frame.minX ||  // Left of screen
               position.x - node.frame.width > frame.maxX ||  // Right of screen
               position.y + node.frame.height < frame.minY || // Below screen
               position.y - node.frame.height > frame.maxY    // Above screen
    }
}
