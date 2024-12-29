import Foundation
import SpriteKit

class GameManager {
    static let shared = GameManager() // Singleton instance

    private var currentState: GameState?

    private init() {
        
    }

    func changeState(to newState: GameState, in view: SKView) {
        currentState?.exit()
        currentState = newState
        currentState?.enter(view: view)
    }

    func update(deltaTime: TimeInterval) {
        currentState?.update(deltaTime: deltaTime)
    }
}
