//
//  naughty.swift
//  AoC 2015
//
//  Created by En David on 21/11/2022.
//

import Foundation

extension Character {
    var isVowel: Bool {
        get {
            let vowels = Set<Character>(["a", "e", "i", "o", "u"])
            return vowels.contains(self)
        }
    }
}

func hasBadSet(_ s: String) -> Bool {
    let badSet = ["ab", "cd", "pq", "xy"]
    for pair in badSet {
        if s.contains(pair) {
            return true
        }
    }
    return false
}

func hasDoubleCharacters(_ s: String) -> Bool {
    var previousChar = Character(".")
    for c in s {
        if previousChar == c {
            return true
        }
        previousChar = c
    }
    return false
}

func isNiceString(_ s: String) -> Bool {
    if hasBadSet(s) {
        return false
    }
    if !hasDoubleCharacters(s) {
        return false
    }
    let filtered = s.filter { $0.isVowel }
    let vowelCount = filtered.count
    return vowelCount >= 3
}

func extractPairs(_ s: String) -> [String] {
    let chars = s.map { String($0) }
    let chunks = chars.chunked(into: 2)
    return chunks.map { $0.joined() }.filter { $0.count == 2 }
}

func hasPairThatAppearsTwice(_ s: String) -> Bool {
    var pairs = Set<String>([])
    extractPairs(s).forEach { pairs.insert($0) }
    let rest = s.substring(from: 1)
    extractPairs(rest).forEach { pairs.insert($0) }
    let range = NSRange(location: 0, length: s.utf8.count)
    for pair in pairs {
        let regex = try! NSRegularExpression(pattern: "\(pair).*\(pair)")
        let result = regex.firstMatch(in: s, range: range)
        if result != nil {
            return true
        }
    }
    return false
}

func hasPairOfSameLetterWithSingleCharBetweenThem(_ s: String) -> Bool {
    var chars = Set<Character>([])
    s.forEach { chars.insert($0) }
    let range = NSRange(location: 0, length: s.utf8.count)
    for c in chars {
        let regex = try! NSRegularExpression(pattern: "\(c).\(c)")
        let result = regex.firstMatch(in: s, range: range)
        if result != nil {
            return true
        }
    }
    return false
}

func isReallyNiceString(_ s: String) -> Bool {
    return hasPairThatAppearsTwice(s) && hasPairOfSameLetterWithSingleCharBetweenThem(s)
}
