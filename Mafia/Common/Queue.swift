//
//  Queue.swift
//  Mafia
//
//  Created by Булат Мусин on 25.12.2022.
//

import Foundation

struct Queue<T> {
    private var list: [T] = []
    
    mutating func enqueue(element: T) {
        list.append(element)
    }
    
    mutating func dequeue() -> T? {
        guard !list.isEmpty else { return nil }
        return list.removeFirst()
    }
}
