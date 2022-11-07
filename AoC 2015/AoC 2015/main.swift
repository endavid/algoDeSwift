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
        let (day, lines) = try parseCLI()
        switch(day) {
        case 1:
            day1(input: lines)
        case 2:
            day2(input: lines)
        default:
            print("Invalid day: \(day)")
        }
    } catch {
        print(error.localizedDescription)
    }
}

advent()
