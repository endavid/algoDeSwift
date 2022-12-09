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

func getTotalPriority(rucksacks: [Rucksack]) -> Int {
    let commonItems = rucksacks.compactMap { $0.getCommonItem() }
    print(commonItems)
    let priorities = commonItems.map { $0.1 }
    return priorities.reduce(0, +)
}

func day3(input: [String]) {
    let rucksacks = input.map { Rucksack($0) }
    // part 1
    let total = getTotalPriority(rucksacks: rucksacks)
    print("sum of priorities is \(total)")
    // part 2
    let trios = input.chunked(into: 3)
    let sacks3 = trios.map { Rucksack($0) }
    let total3 = getTotalPriority(rucksacks: sacks3)
    print("sum of priorities for groups is \(total3)")
}

func day4(input: [String]) {
    let pairs = input.map { RangePair($0) }
    // part 1
    let fullyContained = pairs.filter { $0.oneContainsTheOther }
    print("There are \(fullyContained.count) fully contained pairs.")
    // part 2
    let someOverlap = pairs.filter { $0.overlap }
    print("There are \(someOverlap.count) pairs with some overlap.")

}

func day5(input: [String]) {
    var crateStacks = CrateStacks(input: input)
    print(crateStacks.stacks)
    print(crateStacks.instructions)
    // part 1
    print("top at start: \(crateStacks.top)")
    crateStacks.applyAll()
    print("top when finished: \(crateStacks.top)")
    // part 2
    crateStacks = CrateStacks(input: input)
    crateStacks.applyAllNew()
    print("top when finished: \(crateStacks.top)")
}

func findDistinctCharacters(_ line: String, count: Int) -> Int {
    var i = 0
    while i < line.count {
        let a = line.index(from: i)
        let b = line.index(from: min(i+count, line.count))
        let set = Set<Character>(line[a..<b])
        if set.count == count {
            break
        }
        i += 1
    }
    return i + count
}

func day6(input: [String]) {
    for line in input {
        let startPacket = findDistinctCharacters(line, count: 4)
        let startMessage = findDistinctCharacters(line, count: 14)
        print("start of packet at \(startPacket)")
        print("start of message at \(startMessage)")
    }
}
