import SpriteKit

protocol Component: AnyObject {
    var entity: Entity? { get set }
    
    // Lifecycle methods
    func didAddToEntity()
    func didRemoveFromEntity()
    
    // Optional update method
    func update(deltaTime: TimeInterval)
}

extension Component {
    // Provide default implementations for lifecycle methods
    func didAddToEntity() {
        // Default: no action
    }
    
    func didRemoveFromEntity() {
        // Default: no action
    }
    
    func update(deltaTime: TimeInterval) {
        // Default: no action
    }
}
