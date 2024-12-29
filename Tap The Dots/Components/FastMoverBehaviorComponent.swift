import SpriteKit

class FastMoverBehaviorComponent: Component {
    var entity: Entity?
    
    private let frequency: CGFloat
    private let amplitude: CGFloat
    private var time: CGFloat = 0.0
    private let initialDirection: CGFloat // 1 for right, -1 for left

    init(frequency: CGFloat, amplitude: CGFloat, startsRight: Bool) {
        self.frequency = frequency
        self.amplitude = amplitude
        self.initialDirection = startsRight ? 1 : -1
    }

    func update(deltaTime: TimeInterval) {
        guard let renderComponent = entity?.getComponent(ofType: RenderComponent.self) else { return }
        guard let node = renderComponent.node as? SKShapeNode else { return }

        time += CGFloat(deltaTime)

        // Zig-zag motion using sine wave
        let sineOffset = amplitude * sin(frequency * time) * initialDirection
        node.position.x += sineOffset * CGFloat(deltaTime)

        // Constant downward movement
        node.position.y -= 150 * CGFloat(deltaTime) // Adjust speed as needed
    }
}
