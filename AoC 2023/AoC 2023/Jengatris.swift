//
//  Jengatris.swift
//  AoC 2023
//
//  Created by David Gavilan Ruiz on 03/03/2024.
//

import Foundation

class Jengatris {
    // I use structs because I want to copy all the values, not the references.
    // That will make resetting the state and doing multiple simulations easier
    struct GameState {
        var pieces: [AABB<Int>]
        var volume: VoxelVolume<Int>
    }
    let initialState: GameState
        
    static func simulate(start: GameState, without removedId: Int? = nil) -> (final: GameState, moved: Int) {
        var out = start
        if let id = removedId {
            // Part 2
            out.volume.remove(aabb: out.pieces[id-1])
        }
        var fallCount = 0
        var moved: Set<Int> = [] // for Part 2
        repeat {
            fallCount = 0
            for i in 0..<out.pieces.count {
                let pieceId = i + 1
                if pieceId == removedId {
                    // in part 2, we remove some pieces
                    continue
                }
                let aabb = out.pieces[i]
                let colliders = out.volume.collisionBelow(aabb: aabb)
                if colliders.isEmpty {
                    fallCount += 1
                    out.volume.remove(aabb: aabb)
                    out.pieces[i].moveDown()
                    out.volume.place(pieceId, in: out.pieces[i])
                    moved.insert(i) // Part 2
                }
            }
        } while fallCount > 0
        return (out, moved.count)
    }
    
    /// These are pieces that if removed, something else will fall
    static func findEssentials(state: GameState) -> Set<Int> {
        var out: Set<Int> = []
        for i in 0..<state.pieces.count {
            let aabb = state.pieces[i]
            let colliders = state.volume.collisionBelow(aabb: aabb)
            if colliders.count == 1 && !colliders.contains(0) {
                // a single piece below, and it's not the floor
                let id = colliders.first!
                out.insert(id)
            }
        }
        return out
    }
    
    init(input: [String]) {
        let pieces = input.map { s in
            let p = s.split(separator: "~")
            let a = p[0].split(separator: ",").map { Int($0)! }
            let b = p[1].split(separator: ",").map { Int($0)! }
            return AABB(x0: a[0], y0: a[2], z0: a[1], x1: b[0], y1: b[2], z1: b[1])
        }
        var maxes = (x: 0, y: 0, z: 0)
        for p in pieces {
            if p.x1 > maxes.x {
                maxes.x = p.x1
            }
            if p.y1 > maxes.y {
                maxes.y = p.y1
            }
            if p.z1 > maxes.z {
                maxes.z = p.z1
            }
        }
        var vol = VoxelVolume<Int>(width: maxes.x + 1, depth: maxes.z + 1, height: maxes.y + 1)
        for i in 0..<pieces.count {
            let pieceId = i + 1
            vol.place(pieceId, in: pieces[i])
        }
        initialState = GameState(pieces: pieces, volume: vol)
    }
    
    // AoC 2023 Day 22
    // Part 2 (~1934 ms on M1 mac mini for my input)
    static func countFalls(state: GameState, ids: Set<Int>) -> Int {
        return ids.reduce(0) { sum, i in
            let (_, n) = Jengatris.simulate(start: state, without: i)
            return sum + n
        }
    }
    
    // Part 2 but using Grand Central Dispatch concurrency (~460 ms on M1 mac mini)
    static func concurrentCountFalls(state: GameState, ids: Set<Int>) -> Int {
        let indexArray: [Int] = Array(ids)
        var counts = [Int].init(repeating: 0, count: indexArray.count)
        DispatchQueue.concurrentPerform(iterations: indexArray.count) { iteration in
            let id = indexArray[iteration]
            let (_, n) = Jengatris.simulate(start: state, without: id)
            counts[iteration] = n
        }
        return counts.reduce(0, +)
    }
    
    // Part 2 but using async/await concurrency (~462 ms on my M1)
    class ConcurrentFallCounter {
        let initialState: GameState
        init(state: GameState) {
            initialState = state
        }
        func countFalls(id: Int) -> Int {
            let (_, n) = Jengatris.simulate(start: initialState, without: id)
            return n
        }
        func countFalls(ids: Set<Int>) async -> Int {
            var sum = 0
            await withTaskGroup(of: Int.self) { group in
                for i in ids {
                    group.addTask {
                        return self.countFalls(id: i)
                    }
                }
                for await n in group {
                    sum += n
                }
            }
            return sum
        }
    }
}

extension Task where Failure == Error {
    /// Performs an async task in a sync context.
    ///
    /// - Note: This function blocks the thread until the given operation is finished. The caller is responsible for managing multithreading.
    static func synchronous(priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Success) {
        let semaphore = DispatchSemaphore(value: 0)

        Task(priority: priority) {
            defer { semaphore.signal() }
            return try await operation()
        }

        semaphore.wait()
    }
}
