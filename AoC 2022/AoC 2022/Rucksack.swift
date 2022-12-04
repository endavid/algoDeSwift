//
//  Rucksack.swift
//  AoC 2022
//
//  Created by En David on 04/12/2022.
//

import Foundation

struct Rucksack: CustomStringConvertible {
    var groups: [String]
    
    var description: String {
        get {
            return "\(groups)"
        }
    }
    
    static func getPriority(_ c: Character) -> Int {
        let a = Int(Character("a").asciiValue!)
        let A = Int(Character("A").asciiValue!)
        let v = Int(c.asciiValue!)
        return v >= a ? v - a + 1 : v - A + 27
    }
    
    func getCommonItem() -> (Character, Int)? {
        let sets = groups.map { Set<Character>($0) }
        for c in sets.first! {
            var found = true
            for i in 1..<sets.count {
                if !sets[i].contains(c) {
                    found = false
                }
            }
            if found {
                return (c, Rucksack.getPriority(c))
            }
        }
        return nil
    }
    
    init(_ s: String) {
        let n = s.count / 2
        groups = [s.substring(to: n), s.substring(from: n)]
    }
    init(_ groups: [String]) {
        self.groups = groups
    }
}
