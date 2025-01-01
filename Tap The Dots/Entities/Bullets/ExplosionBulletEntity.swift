//
//  ExplosionBulletEntity.swift
//  Tap The Dots
//
//  Created by Drew Atkison on 12/31/24.
//

import SpriteKit

class ExplosionBulletEntity: PowerUpEntity {
    
    init(scene: GameScene, position: CGPoint, target: CGPoint) {
        super.init(scene: scene, position: position, type: .explosiveBullet)
        
        // Customize the existing render node from PowerUpEntity
        if let renderComponent = getComponent(ofType: RenderComponent.self) {
            let explosionNode = renderComponent.node as! SKShapeNode
            explosionNode.fillColor = .red
            explosionNode.alpha = 0.9
            explosionNode.zPosition = 5
        }

        // Movement Component
        let direction = CGVector(dx: target.x - position.x, dy: target.y - position.y)
        let length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
        guard length > 0 else { return }
        let normalizedDirection = CGVector(dx: direction.dx / length, dy: direction.dy / length)
        let bulletSpeed: CGFloat = 400
        let velocity = CGVector(dx: normalizedDirection.dx * bulletSpeed,
                                 dy: normalizedDirection.dy * bulletSpeed)
        addComponent(MovementComponent(velocity: velocity, acceleration: 0, friction: 1.0))
        addComponent(CollisionComponent(size: CGSize(width: 10, height: 10)))
        let explosionComponent = ExplosionComponent(scene: scene, radius: 50, damageRadius: 200, position: position)
        addComponent(explosionComponent)

        // Schedule Explosion
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.getComponent(ofType: ExplosionComponent.self)?.triggerExplosion()
        }

    }
}
