//
//  week1.swift
//  AoC 2015
//
//  Created by En David on 07/11/2022.
//

import Foundation

func findBasement(_ instructions: String) -> Int {
    var floor = 0
    var position = 1
    for c in instructions {
        floor += (c == "(") ? 1 : -1
        if floor == -1 {
            break
        }
        position += 1
    }
    return position
}

func moveFloor(_ instructions: String) -> Int {
    return instructions.reduce(0) { floor, c in
        floor + ((c == "(") ? 1 : -1)
    }
}

func day1(input: [String]) {
    for line in input {
        let finalFloor = moveFloor(line)
        let basementPosition = findBasement(line)
        print("The final floor is \(finalFloor)")
        print("Basement position is \(basementPosition)")
    }
}

func day2(input: [String]) {
    let boxes = input.map { BoxVolume($0) }
    let areas = boxes.map { $0.surfaceArea + $0.smallestSideArea }
    let total = areas.reduce(0, +)
    print("Total area = \(total) sq-feet")
    let totalRibbon = boxes.map { $0.smallestPerimeter + $0.volume }.reduce(0, +)
    print("Total ribbon = \(totalRibbon) feet")
}

func day3(input: [String]) {
    let bigNumber = 0xf000000
    for instructions in input {
        var visitedHouses: [Int: Int] = [0: 1]
        var position = Coord2D(0, 0)
        for direction in instructions {
            position = updatePosition(coord: position, direction: direction)
            let index = toIndex(coord: position, width: bigNumber)
            visitedHouses[index, default: 0] += 1
        }
        // part 1
        print("#visitedHouses = \(visitedHouses.count)")
        // part 2
        visitedHouses = [0: 2]
        position = Coord2D(0, 0)
        var positionRobot = Coord2D(0, 0)
        var isSanta = true
        for direction in instructions {
            var index = 0
            if isSanta {
                position = updatePosition(coord: position, direction: direction)
                index = toIndex(coord: position, width: bigNumber)
            } else {
                positionRobot = updatePosition(coord: positionRobot, direction: direction)
                index = toIndex(coord: positionRobot, width: bigNumber)
            }
            isSanta = !isSanta
            visitedHouses[index, default: 0] += 1
        }
        print("#visited houses (with robot) = \(visitedHouses.count)")
    }
}

func day4(input: [String]) {
    var lowestIndex = 0
    // part 1
    for key in input {
        let (hash, md5, i) = findHashWithMD5That(startsWith: "00000", key: key)
        print("\(key) -> \(hash): \(md5)")
        lowestIndex = i
    }
    // part 2
    let key = input.last!
    let (h, m, _) = findHashWithMD5That(startsWith: "000000", key: key, start: lowestIndex)
    print("\(key) -> \(h): \(m)")
}
