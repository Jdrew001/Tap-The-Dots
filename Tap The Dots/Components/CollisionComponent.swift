import SpriteKit

class CollisionComponent: Component {
    var entity: Entity?
    let size: CGSize
    let isCircular: Bool
    var onCollision: ((Entity) -> Void)?

    init(size: CGSize, isCircular: Bool = false, onCollision: ((Entity) -> Void)? = nil) {
        self.size = size
        self.isCircular = isCircular
        self.onCollision = onCollision
    }

    func checkCollision(with other: CollisionComponent) -> Bool {
        guard let node = entity?.getComponent(ofType: RenderComponent.self)?.node else { return false }
        guard let otherNode = other.entity?.getComponent(ofType: RenderComponent.self)?.node else { return false }

        if isCircular && other.isCircular {
            // Circular collision detection
            let dx = node.position.x - otherNode.position.x
            let dy = node.position.y - otherNode.position.y
            let distance = sqrt(dx * dx + dy * dy)
            let combinedRadius = size.width / 2 + other.size.width / 2
            return distance <= combinedRadius
        } else {
            // Rectangular collision detection
            return node.frame.intersects(otherNode.frame)
        }
    }

    func handleCollision(with other: CollisionComponent) {
        onCollision?(other.entity!)
    }
}
