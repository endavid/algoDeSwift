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

/// When calling an asynchronous method, execution suspends until that method returns.
/// You write await in front of the call to mark the possible suspension point.
func asyncOp<T>(_ value: T, op: @escaping (T) -> T) async -> T {
    // Inside an asynchronous method, the flow of execution is suspended only when you call another asynchronous method — suspension is never implicit or preemptive — which means every possible suspension point is marked with await.
    return op(value)
}

func asyncOp<T>(_ values: [T], op: @escaping (T) -> T) async -> [T] {
    var out: [T] = []
    await withTaskGroup(of: T.self) { group in
        for v in values {
            group.addTask {
                return op(v)
            }
        }
        for await v in group {
            out.append(v)
        }
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
