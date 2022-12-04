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
        let (day, lines, output) = try parseCLI()
        switch(day) {
        case 1:
            day1(input: lines)
        case 2:
            day2(input: lines)
        case 3:
            day3(input: lines)
        default:
            print("Invalid day: \(day)")
        }
    } catch {
        print(error.localizedDescription)
    }
}

advent()


