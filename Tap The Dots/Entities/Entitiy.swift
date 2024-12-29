import SpriteKit

class Entity {
    private var components: [Component] = []

    func addComponent(_ component: Component) {
        components.append(component)
        component.entity = self
        component.didAddToEntity() // Lifecycle hook
    }

    func removeComponent<T: Component>(ofType type: T.Type) {
        if let index = components.firstIndex(where: { $0 is T }) {
            let component = components.remove(at: index)
            component.didRemoveFromEntity() // Lifecycle hook
        }
    }

    func getComponent<T: Component>(ofType type: T.Type) -> T? {
        return components.first { $0 is T } as? T
    }

    func update(deltaTime: TimeInterval) {
        components.forEach { $0.update(deltaTime: deltaTime) }
    }
}
