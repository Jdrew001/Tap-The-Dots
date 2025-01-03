//
//  PlayingState.swift
//  Tap The Dots
//
//  Created by Drew Atkison on 12/22/24.
//

import Foundation
import SpriteKit

class PlayingState: GameState {
    
    func enter(view: SKView) {
        SceneManager.transition(to: GameScene(size: view.bounds.size), in: view)
    }
    
    func update(deltaTime: TimeInterval) {
    }
    
    func exit() {
    }
}
