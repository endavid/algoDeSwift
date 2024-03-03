//
//  Week4.swift
//  AoC 2023
//
//  Created by David Gavilan Ruiz on 03/03/2024.
//

import Foundation

func day22(input: [String]) {
    // Part 1
    let jengatris = Jengatris(input: input)
    //jengatris.initialState.volume.dump()
    let (firstFall, _) = Jengatris.simulate(start: jengatris.initialState)
    //firstFall.volume.dump()
    let essentials = Jengatris.findEssentials(state: firstFall)
    //print(essentials)
    let disposableCount = jengatris.initialState.pieces.count - essentials.count
    print("There are \(disposableCount) disposable pieces")
    // Part 2
    let t1 = measure {
        let n = Jengatris.countFalls(state: firstFall, ids: essentials)
        print("\(n) bricks would fall.")
    }
    print("Took \(t1 * 1_000) ms to simulate.")
    let t2 = measure {
        Task.synchronous {
            let cfc = Jengatris.ConcurrentFallCounter(state: firstFall)
            let n = await cfc.countFalls(ids: essentials)
            print("\(n) bricks would fall.")
        }
    }
    print("Took \(t2 * 1_000) ms to simulate (async/await)")
    let t3 = measure {
        let n = Jengatris.concurrentCountFalls(state: firstFall, ids: essentials)
        print("\(n) bricks would fall.")
    }
    print("Took \(t3 * 1_000) ms to simulate (Grand Central Dispatch)")
}

