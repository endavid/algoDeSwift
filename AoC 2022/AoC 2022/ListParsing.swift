//
//  ListParsing.swift
//  AoC 2022
//
//  Created by En David on 19/11/2023.
//

import Foundation

// http://stackoverflow.com/a/33674192/1765629
extension Collection where Index: Strideable {
    /// Finds such index N that predicate is true for all elements up to
    /// but not including the index N, and is false for all elements
    /// starting with index N.
    /// Behavior is undefined if there is no such N.
    func binarySearch(_ predicate: (Iterator.Element) -> Bool) -> Index {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = self.index(low, offsetBy: self.distance(from: low, to: high) / 2)
            if predicate(self[mid]) {
                low = self.index(mid, offsetBy: 1)
            } else {
                high = mid
            }
        }
        return low
    }
}

func extractList(_ s: String) -> [String] {
    var s1 = s.substring(from: 1, to: s.count - 1)
    var out: [String] = []
    while !s1.isEmpty {
        if s1.first == "[" {
            var i = 0
            var depth = 1
            while depth > 0 {
                i += 1
                while s1[s1.index(from: i)] != "]" {
                    let c = s1[s1.index(from: i)]
                    if c == "[" {
                        depth += 1
                    }
                    i += 1
                }
                depth -= 1
            }
            i += 1
            out.append(s1.substring(from: 0, to: i))
            if i == s1.count {
                s1 = ""
            } else {
                // there should be a comma next: [...], ....
                s1 = s1.substring(from: i + 1, to: s1.count)
            }
        } else {
            if let c = s1.firstIndex(of: ",") {
                let a = s1.startIndex
                let item = String(s1[a..<c])
                out.append(item)
                let b = s1.index(c, offsetBy: 1)
                s1 = String(s1[b...])
            } else {
                out.append(s1)
                s1 = ""
            }
        }
    }
    return out
}

// returns -1 is left < right, 0 if left == right, 1 if left > right
func compareLists(_ left: String, _ right: String) -> Int {
    if left.count == 0 && right.count == 0 {
        return 0
    }
    if left.count == 0 {
        return -1
    }
    if right.count == 0 {
        return 1
    }
    if left.first! == "[" {
        if right.first! == "[" {
            // extract lists
            let listL = extractList(left)
            let listR = extractList(right)
            for i in 0..<listL.count {
                if i >= listR.count {
                    return 1
                }
                let v = compareLists(listL[i], listR[i])
                if v != 0 {
                    return v
                }
            }
            if listL.count < listR.count {
                return -1
            }
            return 0
        }
        return compareLists(left, "[\(right)]")
    } else if right.first! == "[" {
        return compareLists("[\(left)]", right)
    }
    if let a = Int(left), let b = Int(right) {
        if a == b {
            return 0
        }
        return a < b ? -1 : 1
    }
    print("Unexpected! (\(left), \(right))")
    return 0
}
