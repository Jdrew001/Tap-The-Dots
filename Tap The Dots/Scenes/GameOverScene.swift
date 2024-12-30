import SpriteKit

class GameOverScene: SKScene {
    private let score: Int
    private let highScore: Int
    
    init(size: CGSize, score: Int, highScore: Int) {
        self.score = score
        self.highScore = highScore
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black

        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 100
        gameOverLabel.fontColor = .red
        gameOverLabel.fontName = "Upheaval TT (BRK)"
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        addChild(gameOverLabel)

        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontSize = 40
        scoreLabel.fontName = "Upheaval TT (BRK)"
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(scoreLabel)

        let highScoreLabel = SKLabelNode(text: "High Score: \(highScore)")
        highScoreLabel.fontSize = 40
        highScoreLabel.fontName = "Upheaval TT (BRK)"
        highScoreLabel.fontColor = .green
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        addChild(highScoreLabel)

        let restartLabel = SKLabelNode(text: "Press Enter to Restart")
        restartLabel.fontSize = 20
        restartLabel.fontName = "Upheaval TT (BRK)"
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        addChild(restartLabel)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 36 {
            EventManager.shared.notify(event: "StartGame")
        }
    }
}
