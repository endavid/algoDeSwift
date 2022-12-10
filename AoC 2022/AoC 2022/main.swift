//
//  main.swift
//  AoC 2022
//
//  Created by En David on 02/12/2022.
//

import Foundation

func advent() {
    // https://adventofcode.com/2022
    do {
        let (day, lines, _) = try parseCLI()
        switch(day) {
        case 1:
            day1(input: lines)
        case 2:
            day2(input: lines)
        case 3:
            day3(input: lines)
        case 4:
            day4(input: lines)
        case 5:
            day5(input: lines)
        case 6:
            day6(input: lines)
        case 7:
            day7(input: lines)
        default:
            print("Invalid day: \(day)")
        }
    } catch {
        print(error.localizedDescription)
    }
}

advent()


