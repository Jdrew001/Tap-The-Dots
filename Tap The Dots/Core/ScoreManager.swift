class ScoreManager {
    static let shared = ScoreManager()

    private var score: Int = 0
    private var listeners: [(Int) -> Void] = []

    private init() {}

    // Increment the score
    func increment(by value: Int) {
        score += value
        notifyListeners()
    }

    // Reset the score
    func reset() {
        score = 0
        notifyListeners()
    }

    // Get the current score
    func getScore() -> Int {
        return score
    }

    // Subscribe to score updates
    func subscribe(listener: @escaping (Int) -> Void) {
        listeners.append(listener)
        print("Listener subscribed. Total listeners: \(listeners.count)") // Debug log
        listener(score) // Immediately notify the new listener with the current score
    }

    private func notifyListeners() {
        print("Notifying \(listeners.count) listeners with score: \(score)") // Debug log
        listeners.forEach { $0(score) }
    }
}
