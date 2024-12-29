import Foundation
import SpriteKit

class MenuState: GameState {
    func enter(view: SKView) {
        print("Entering Menu State")
        let scene = MenuScene(size: view.bounds.size)
        SceneManager.transition(to: scene, in: view)
    }

    func update(deltaTime: TimeInterval) {}

    func exit() {
        print("Exiting Menu State")
        
    }
}
