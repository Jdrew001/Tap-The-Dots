import Foundation
import SpriteKit

class MenuState: GameState {
    func enter(view: SKView) {
        let scene = MenuScene(size: view.bounds.size)
        SceneManager.transition(to: scene, in: view)
    }

    func update(deltaTime: TimeInterval) {}

    func exit() {        
    }
}
