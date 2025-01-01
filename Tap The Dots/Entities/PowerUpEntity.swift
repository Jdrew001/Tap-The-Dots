//
//  PowerUpEntity.swift
//  Tap The Dots
//
//  Created by Drew Atkison on 12/31/24.
//

import SpriteKit

class PowerUpEntity: Entity {
    enum PowerUpType {
        case explosiveBullet
        case shield
        case tripleShot
        case slowTime
        case unassigned
    }
    
    let type: PowerUpType
    
    init(scene: SKScene, position: CGPoint, type: PowerUpType) {
        self.type = type
        super.init()
        
        // Render Component
        let powerUpNode = SKShapeNode(circleOfRadius: 15)
        powerUpNode.fillColor = .blue
        powerUpNode.strokeColor = .white
        powerUpNode.glowWidth = 5
        powerUpNode.position = position
        scene.addChild(powerUpNode)
        addComponent(RenderComponent(node: powerUpNode))
        
        // Collision Component
        addComponent(CollisionComponent(size: CGSize(width: 30, height: 30)) { [weak self] entity in
            guard let player = entity as? PlayerEntity else { return }
            self?.applyPowerUp(to: player)
            self?.destroy()
        })
    }
    
    func applyPowerUp(to player: PlayerEntity) {
        guard let scene = player.getComponent(ofType: RenderComponent.self)?.node.scene as? GameScene else { return }

        switch type {
        case .explosiveBullet:
            // Activate explosive bullets for a limited duration
            scene.spawnManager.activateExplosiveBullets(duration: 20.0)
            
        case .shield:
            // Enable player shield for 10 seconds
            player.activateShield(duration: 10.0)
            
        case .tripleShot:
            // Activate triple shot for a limited duration
            scene.spawnManager.activateTripleShot(duration: 20.0)
            
        case .slowTime:
            // Slow down time in the game
            scene.activateTimeSlow(duration: 5.0)
        default:break
        }
    }
}
