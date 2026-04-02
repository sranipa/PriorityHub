//
//  ConcurrencyUtils.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/31/26.
//

import Foundation
import Firebase

// Created this wrapper for remove Listener.
// we can't directly call because firebase is not returing sendable object of ListenerRegistration
nonisolated final class ListenerBox: @unchecked Sendable {
    
    var listener : any ListenerRegistration
    
    init(listener: any ListenerRegistration) {
        self.listener = listener
    }
    
    func stop() {
        self.listener.remove()
    }
}
