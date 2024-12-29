//
//  EventManager.swift
//  Tap The Dots
//
//  Created by Drew Atkison on 12/22/24.
//

import Foundation

class EventManager {
    static let shared = EventManager()
    
    private var listeners: [String: [() -> Void]] = [:]
    
    private init() {}
    
    func subscribe(event: String, action: @escaping () -> Void) {
           if listeners[event] == nil {
               listeners[event] = []
           }
           listeners[event]?.append(action)
    }
    
    // Notify all listeners of an event
    func notify(event: String) {
        listeners[event]?.forEach { $0() }
    }

    // Unsubscribe all listeners for a specific event
    func unsubscribe(event: String) {
        listeners[event] = nil
    }

    // Unsubscribe a specific listener (Optional Improvement)
    func unsubscribe(event: String, action: @escaping () -> Void) {
        if let index = listeners[event]?.firstIndex(where: { $0 as AnyObject === action as AnyObject }) {
            listeners[event]?.remove(at: index)
        }
    }
}
