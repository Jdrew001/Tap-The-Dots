import SpriteKit

class FastMoverEnemyEntity: Entity {
    // Make frequency and amplitude accessible
    let frequency: CGFloat
    let amplitude: CGFloat
    let startsRight: Bool

    init(scene: SKScene, difficultyFactor: CGFloat) {
        // Randomize zig-zag behavior
        self.frequency = CGFloat.random(in: 2.0...12.0) // Adjust for more/less frequent zig-zags
        self.amplitude = CGFloat.random(in: 30.0...70.0) // Adjust for wider/narrower zig-zags
        self.startsRight = Bool.random() // Randomize initial direction (right or left)
        
        super.init()
        let size = CGSize(width: 30, height: 30)
        let neonColor = GameUtils.randomNeonColor()
        
        // Render Component
        let fastMoverNode = SKShapeNode(rectOf: size, cornerRadius: 5)
        fastMoverNode.fillColor = neonColor // Transparent background
        fastMoverNode.strokeColor = neonColor // Neon color
        fastMoverNode.lineWidth = 8      // Width of the neon border
        fastMoverNode.glowWidth = 5      // Glow effect
        fastMoverNode.blendMode = .add   // Additive blend for neon effect
        fastMoverNode.position = CGPoint(
            x: CGFloat.random(in: 0...scene.size.width),
            y: scene.size.height + 30
        )
        scene.addChild(fastMoverNode)
        addComponent(RenderComponent(node: fastMoverNode))
        
        // Movement Component
        addComponent(MovementComponent(velocity: CGVector(dx: 0, dy: -400 * difficultyFactor),
                                       acceleration: 0,
                                       friction: 1.0))
        
        // Collision Component
        addComponent(CollisionComponent(size: CGSize(width: 30, height: 30)) { [weak self] _ in
            self?.triggerExplosionAndDestroy()
        })
        
        addComponent(FastMoverBehaviorComponent(frequency: self.frequency, amplitude: self.amplitude, startsRight: self.startsRight))
        addComponent(TrailComponent(color: neonColor, size: size, difficultyFactor: 1.0))
        addComponent(EnemyExplodingComponent(
            scene: scene as! GameScene,
            position: fastMoverNode.position,
            nodeColor: neonColor
        ))
    }
    
    private func triggerExplosionAndDestroy() {
        guard let explosionComponent = getComponent(ofType: EnemyExplodingComponent.self) else {
            print("EnemyExplodingComponent not found")
            return
        }

        // Trigger the explosion effect
        if let explodingComponent = getComponent(ofType: EnemyExplodingComponent.self) {
            explodingComponent.triggerExplosion()
        }

        // Delay entity destruction until the explosion effect is done
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.destroy()
        }
    }
}
