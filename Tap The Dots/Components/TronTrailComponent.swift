import SpriteKit

class TronTrailComponent: Component {
    var entity: Entity?
    private let trailNode: SKShapeNode
    private let maxTrailLength: Int
    private var points: [CGPoint]
    private var trailColor: SKColor

    init(color: SKColor, maxTrailLength: Int = 50) {
        self.trailNode = SKShapeNode()
        self.points = []
        self.trailColor = color
        self.maxTrailLength = maxTrailLength

        trailNode.strokeColor = color
        trailNode.lineWidth = 5.0 // Adjust trail thickness
        trailNode.zPosition = -1 // Render behind the entity
        trailNode.blendMode = .alpha
    }

    func didAddToEntity() {
        guard let renderComponent = entity?.getComponent(ofType: RenderComponent.self) else { return }
        renderComponent.node.addChild(trailNode)
    }

    func update(deltaTime: TimeInterval) {
        guard let renderComponent = entity?.getComponent(ofType: RenderComponent.self) else { return }
        let nodePosition = renderComponent.node.position

        // Add the current position to the trail
        points.append(nodePosition)
        if points.count > maxTrailLength {
            points.removeFirst()
        }

        // Update trail path and alpha gradient
        updateTrailPath()
    }

    private func updateTrailPath() {
        guard points.count > 1 else { return }

        let path = CGMutablePath()
        path.addLines(between: points)
        trailNode.path = path

        // Apply gradient alpha along the trail
        applyGradientAlpha()
    }

    private func applyGradientAlpha() {
        guard points.count > 1 else { return }

        // Create a gradient shader with color and alpha blending
        let trailShader = SKShader(source: """
        void main() {
            float progress = v_tex_coord.x; // Horizontal texture coordinate
            float alpha = mix(1.0, 0.1, progress); // Fade from 1.0 to 0.1
            gl_FragColor = vec4(u_color.r, u_color.g, u_color.b, alpha); // Apply alpha to the color
        }
        """)

        // Extract color components
        let color = trailColor.usingColorSpace(.sRGB)!
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Pass the color as a uniform
        trailShader.uniforms = [
            SKUniform(name: "u_color", vectorFloat3: vector_float3(Float(red), Float(green), Float(blue)))
        ]

        trailNode.strokeShader = trailShader
    }

    func updateTrailColor(to color: SKColor) {
        trailColor = color
        trailNode.strokeColor = color
    }
}
