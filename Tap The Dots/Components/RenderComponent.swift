import SpriteKit

class RenderComponent: Component {
    var entity: Entity?
    let node: SKNode

    init(node: SKNode) {
        self.node = node
    }
}
