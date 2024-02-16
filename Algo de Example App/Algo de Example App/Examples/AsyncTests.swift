//
//  AsyncTests.swift
//  Algo de Example App
//
//  Created by David Gavilan Ruiz on 16/02/2024.
//

import Foundation

// Add a protocol for types with a default initializer
protocol DefaultInitializable {
    init()
}

extension String: DefaultInitializable {}

class MyQueues {
    static let concurrent = {
        return DispatchQueue(label: "concurrent", attributes: .concurrent)
    }()
}

/// An async operation using DispatchQueue
func asyncOpDQ<T>(_ value: T, op: @escaping (T) -> T, completion: @escaping (T) -> Void) {
    MyQueues.concurrent.async {
        completion(op(value))
    }
}

/// Async operation on an array, keeping the order
func asyncOpDQ<T: DefaultInitializable>(_ values: [T], op: @escaping (T) -> T, completion: @escaping ([T]) -> Void) {
    MyQueues.concurrent.async {
        var out = [T].init(repeating: T(), count: values.count)
        let semaphore = DispatchSemaphore(value: 0)
        for i in 0..<values.count {
            asyncOpDQ(values[i], op: op) { v in
                out[i] = v
                semaphore.signal()
            }
        }
        for _ in 0..<values.count {
            semaphore.wait()
        }
        completion(out)
    }
}

func concurrentDQ<T: DefaultInitializable>(_ values: [T], op: @escaping (T) -> T) -> [T] {
    var out = [T].init(repeating: T(), count: values.count)
    DispatchQueue.concurrentPerform(iterations: values.count) { iteration in
        out[iteration] = op(values[iteration])
    }
    return out
}

func colorToEmoji(_ s: String) -> String {
    let table = ["red": "❤️",
                 "green": "💚",
                 "blue": "💙",
                 "yellow": "💛",
                 "magenta": "🩷",
                 "cyan": "🩵",
                 "black": "🖤"
    ]
    // This random delay is to test the concurrency respects the order
    let randomDelay = Double.random(in: 0.1...1.0)
    Thread.sleep(forTimeInterval: randomDelay)
    return table[s] ?? "⁉️"
}
