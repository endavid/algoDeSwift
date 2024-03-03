//
//  main.swift
//  AoC 2023
//
//  Created by David Gavilan Ruiz on 03/03/2024.
//

import Foundation

@main
struct Advent {
    static func main() {
        // https://adventofcode.com/2023
        do {
            let (day, lines, _) = try parseCLI()
            switch(day) {
            case 22:
                day22(input: lines)
            default:
                print("Invalid day: \(day)")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

