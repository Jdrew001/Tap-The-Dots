import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.skView {
            GameManager.shared.changeState(to: MenuState(), in: skView)
            
            EventManager.shared.subscribe(event: "StartGame") {
                GameManager.shared.changeState(to: PlayingState(), in: view)
            }
            
            EventManager.shared.subscribe(event: "GameOver") {
                GameManager.shared.changeState(to: GameOverState(), in: view)
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // Set the skView as the first responder
        self.view.window?.makeFirstResponder(self.skView)
        
        // Make the window full screen
        if let window = self.view.window {
            window.toggleFullScreen(nil)
        }
    }

    func showMenuScene() {
        let scene = MenuScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
    }

    func showGameScene() {
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
    }

    func showGameOverScene() {
        let scene = GameOverScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
    }
}
