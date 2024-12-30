class ScoreManager {
    static let shared = ScoreManager()

    private var score: Int = 0 {
        didSet {
            notifyObservers()
        }
    }
    private(set) var highScore: Int = 0
    private var observers: [(Int) -> Void] = []
    private var hasNotifiedHighScore: Bool = false // Track notification status

    // Subscribe method
    func subscribe(_ observer: @escaping (Int) -> Void) {
        observers.append(observer)
    }

    private func notifyObservers() {
        for observer in observers {
            observer(score)
        }
    }

    func increment(by points: Int) {
        if highScore == 0 {
            hasNotifiedHighScore = true
        }
        print ("highscore", highScore)
        score += points
        updateHighScoreIfNeeded()
    }

    func reset() {
        score = 0
        hasNotifiedHighScore = false // Reset notification flag
    }

    func getScore() -> Int {
        return score
    }

    func updateHighScoreIfNeeded() {
        if score > highScore {
            highScore = score
            
            // Notify via EventManager only if the high score is non-zero and not yet notified
            if highScore > 0 && !hasNotifiedHighScore {
                EventManager.shared.notify(event: "HighScoreUpdated")
                hasNotifiedHighScore = true // Mark as notified
            }
        }
    }
}
