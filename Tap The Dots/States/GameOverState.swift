//
//  GameOverState.swift
//  Tap The Dots
//
//  Created by Drew Atkison on 12/22/24.
//

import Foundation
import SpriteKit

class GameOverState: GameState {
    func enter(view: SKView) {
        print("Entering Game Over State")
        SceneManager.transition(to: GameOverScene(size: view.bounds.size), in: view, with: SKTransition.fade(withDuration: 0.4))
    }

    func update(deltaTime: TimeInterval) {}

    func exit() {
        print("Exiting Game Over State")
    }
}
