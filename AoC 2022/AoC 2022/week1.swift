//
//  week1.swift
//  AoC 2022
//
//  Created by En David on 02/12/2022.
//

import Foundation

func day1(input: [String]) {
    var elves: [[Int]] = []
    var i = 0
    while i < input.count {
        var line = input[i]
        var carrying: [Int] = []
        while !line.isEmpty {
            if let n = Int(line) {
                carrying.append(n)
            }
            i += 1
            if i == input.count {
                break
            }
            line = input[i]
        }
        elves.append(carrying)
        i += 1
    }
    // part 1
    let totals = elves.map { $0.reduce(0, +) }
    let maxCalories = totals.reduce(0, { max($0, $1) })
    print("maxCalories = \(maxCalories)")
    // part 2
    let ordered = totals.sorted(by: >)
    let sumTop3 = ordered[0] + ordered[1] + ordered[2]
    print("caloriesTop3 = \(sumTop3)")
}

func day2(input: [String]) {
    let rps = RockPaperScissors()
    // part 1
    let total = rps.playStrategy(input: input)
    print("finalScore = \(total)")
    // part 2
    let rightTotal = rps.playRightStrategy(input: input)
    print("rightTotal = \(rightTotal)")
}

