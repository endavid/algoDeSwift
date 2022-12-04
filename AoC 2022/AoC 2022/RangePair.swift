//
//  RangePair.swift
//  AoC 2022
//
//  Created by En David on 04/12/2022.
//

import Foundation

struct RangePair: CustomStringConvertible {
    let elf1: ClosedRange<Int>
    let elf2: ClosedRange<Int>
    
    var description: String {
        get {
            return "(\(elf1), \(elf2))"
        }
    }
    
    var oneContainsTheOther: Bool {
        get {
            return elf1.contains(elf2) || elf2.contains(elf1)
        }
    }
    
    var overlap: Bool {
        get {
            return elf1.overlaps(elf2)
        }
    }
    
    static func parseRange(_ s: Substring) -> ClosedRange<Int> {
        let numbers = s.split(separator: "-").compactMap { Int($0) }
        return numbers[0]...numbers[1]
    }
    
    init(_ s: String) {
        // "2-4,6-8"
        let ranges = s.split(separator: ",")
        elf1 = RangePair.parseRange(ranges[0])
        elf2 = RangePair.parseRange(ranges[1])
    }
}
