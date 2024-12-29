//
//  GameState.swift
//  Tap The Dots
//
//  Created by Drew Atkison on 12/22/24.
//

import Foundation
import SpriteKit

protocol GameState {
    func enter(view: SKView)
    func update(deltaTime: TimeInterval)
    func exit()
}
