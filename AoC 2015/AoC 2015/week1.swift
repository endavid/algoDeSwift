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
