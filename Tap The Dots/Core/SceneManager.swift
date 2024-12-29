import SpriteKit

class SceneManager {
    static func transition(to scene: SKScene, in view: SKView, with transition: SKTransition = SKTransition.fade(withDuration: 1.0)) {
        scene.scaleMode = .aspectFill
        view.presentScene(scene, transition: transition)
    }
}
