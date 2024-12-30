import SpriteKit

class ScrollingBackground: SKNode {
    private let texture: SKTexture
    private var sprites: [SKSpriteNode] = []
    private let scrollSpeed: CGFloat // Renamed from `speed`

    init(imageName: String, scrollSpeed: CGFloat, sceneSize: CGSize) {
        self.texture = SKTexture(imageNamed: imageName)
        self.scrollSpeed = scrollSpeed
        super.init()

        // Determine the scaling factor to fill the screen
        let textureSize = texture.size()
        let scaleWidth = sceneSize.width / textureSize.width
        let scaleHeight = sceneSize.height / textureSize.height
        let scale = max(scaleWidth, scaleHeight)

        // Determine how many sprites are needed to fill the screen height
        let spriteCount = Int(ceil(sceneSize.height / (textureSize.height * scale))) + 1

        for i in 0..<spriteCount {
            let sprite = SKSpriteNode(texture: texture)
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
            sprite.position = CGPoint(x: sceneSize.width / 2, y: CGFloat(i) * textureSize.height * scale)
            sprite.size = CGSize(width: textureSize.width * scale, height: textureSize.height * scale)
            addChild(sprite)
            sprites.append(sprite)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(deltaTime: TimeInterval) {
        let offset = scrollSpeed * CGFloat(deltaTime)
        for sprite in sprites {
            sprite.position.y -= offset

            // Loop the sprite when it goes off-screen
            if sprite.position.y + sprite.size.height < 0 {
                sprite.position.y += sprite.size.height * CGFloat(sprites.count)
            }
        }
    }
}
