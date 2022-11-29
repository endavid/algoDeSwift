//
//  main.swift
//  AoC 2015
//
//  Created by En David on 07/11/2022.
//

import Foundation

func advent() {
    // https://adventofcode.com/2015
    do {
        let (day, lines, output) = try parseCLI()
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
            try day6(input: lines, output: output)
        default:
            print("Invalid day: \(day)")
        }
    } catch {
        print(error.localizedDescription)
    }
}

advent()
