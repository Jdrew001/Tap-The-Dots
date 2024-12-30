import SpriteKit

class PerlinNoiseBehaviorComponent: Component {
    var entity: Entity?

    private var time: CGFloat = 0.0
    private let speed: CGFloat
    private let amplitude: CGFloat
    private let perlinNoise: PerlinNoise
    private let noiseOffsetX: CGFloat
    private let noiseOffsetY: CGFloat

    init(speed: CGFloat, amplitude: CGFloat, noiseScale: CGFloat, seed: UInt64) {
        self.speed = speed
        self.amplitude = amplitude
        self.perlinNoise = PerlinNoise(seed: seed, noiseScale: noiseScale)
        self.noiseOffsetX = CGFloat.random(in: 0...1000)
        self.noiseOffsetY = CGFloat.random(in: 0...1000)
    }

    func update(deltaTime: TimeInterval) {
        guard let renderComponent = entity?.getComponent(ofType: RenderComponent.self) else { return }

        // Increment time with a smaller multiplier for smoother transitions
        time += CGFloat(deltaTime) * 0.5 // Slower evaluation for smoother motion

        // Generate Perlin noise offsets
        let perlinValueX = perlinNoise.noise(x: noiseOffsetX + time, y: 0)
        let perlinValueY = perlinNoise.noise(x: noiseOffsetY + time, y: 0)

        // Calculate offsets using scaled Perlin values
        let offsetX = perlinValueX * amplitude
        let offsetY = -speed * CGFloat(deltaTime) + (perlinValueY * amplitude * 0.1)

        // Update position
        let node = renderComponent.node
        node.position.x += offsetX * CGFloat(deltaTime)
        node.position.y += offsetY
    }
}
