//
//  PhaseManager.swift
//  Tap The Dots
//
//  Created by Drew Atkison on 12/25/24.
//

import Foundation

class PhaseManager {
    static let shared = PhaseManager()

    private(set) var currentPhase: Int = 1 // Start at phase one
    private var elapsedTime: TimeInterval = 0
    
    func getSettings(for phase: Int) -> PhaseSettings {
        switch phase {
        case 1:
            return PhaseSettings(currentPhase: phase, obstacleSpeed: 200, enemyTypes: ["Shooter"])
        case 2:
            return PhaseSettings(currentPhase: phase, obstacleSpeed: 300, enemyTypes: ["FastMover"])
        case 3:
            return PhaseSettings(currentPhase: phase, obstacleSpeed: 400, enemyTypes: ["Basic", "FastMover"])
        case 4:
            return PhaseSettings(currentPhase: phase, obstacleSpeed: 300, enemyTypes: ["Shooter"])
        case 5:
            return PhaseSettings(currentPhase: phase, obstacleSpeed: 475, enemyTypes: ["FastMover"])
        case 6:
            return PhaseSettings(currentPhase: phase, obstacleSpeed: 350, enemyTypes: ["Shooter"])
        default:
            return PhaseSettings(currentPhase: phase, obstacleSpeed: 200, enemyTypes: ["Basic"])
        }
    }
    
    // Advance to the next phase based on elapsed time or conditions
    func updatePhase(deltaTime: TimeInterval) {
        elapsedTime += deltaTime
        if elapsedTime > 30 && currentPhase < 7 { // Example: Change phase every 30 seconds
            currentPhase += 1
            elapsedTime = 0 // Reset timer for the next phase
        }
    }
    
    func reset() {
        currentPhase = 1
        elapsedTime = 0
    }
}
