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
        // Get the current score and high score from the ScoreManager
        let score = ScoreManager.shared.getScore()
        let highScore = ScoreManager.shared.highScore

        // Create the GameOverScene with score and highScore
        let gameOverScene = GameOverScene(size: view.bounds.size, score: score, highScore: highScore)

        // Transition to the GameOverScene
        SceneManager.transition(to: gameOverScene, in: view, with: SKTransition.fade(withDuration: 0.4))
    }

    func update(deltaTime: TimeInterval) {}

    func exit() {}
}
