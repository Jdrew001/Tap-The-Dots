import SpriteKit

class MovementComponent: Component {
    var entity: Entity?

    var velocity: CGVector
    let acceleration: CGFloat
    let friction: CGFloat

    init(velocity: CGVector = .zero, acceleration: CGFloat, friction: CGFloat) {
        self.velocity = velocity
        self.acceleration = acceleration
        self.friction = friction
    }

    func applyInput(direction: CGVector) {
        velocity.dx += direction.dx * acceleration
        velocity.dy += direction.dy * acceleration

        // Clamp velocity to prevent excessive speed
        let maxSpeed: CGFloat = 800
        velocity.dx = max(min(velocity.dx, maxSpeed), -maxSpeed)
        velocity.dy = max(min(velocity.dy, maxSpeed), -maxSpeed)
    }

    func update(deltaTime: TimeInterval) {
        guard let renderComponent = entity?.getComponent(ofType: RenderComponent.self) else { return }

        let timeFactor = CGFloat(deltaTime)
        renderComponent.node.position.x += velocity.dx * timeFactor
        renderComponent.node.position.y += velocity.dy * timeFactor

        // Apply friction to gradually slow down
        velocity.dx *= friction
        velocity.dy *= friction
    }
}
