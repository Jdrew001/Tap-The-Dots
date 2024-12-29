import SpriteKit

class GameOverScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .black

        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 100
        gameOverLabel.fontColor = .red
        gameOverLabel.fontName = "Upheaval TT (BRK)"
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gameOverLabel)

        let restartLabel = SKLabelNode(text: "Press Enter to Restart")
        restartLabel.fontSize = 20
        restartLabel.fontName = "Upheaval TT (BRK)"
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        addChild(restartLabel)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 36 {
            EventManager.shared.notify(event: "StartGame")
        }
    }
}
