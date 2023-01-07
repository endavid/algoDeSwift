//
//  Math.swift
//  AoC 2022
//
//  Created by En David on 07/01/2023.
//

import Foundation

struct Vec2: Hashable, CustomStringConvertible {
    static let zero = Vec2(0,0)
    
    let x: Int
    let y: Int
    
    var description: String {
        get {
            return "(\(x), \(y))"
        }
    }
    
    init(_ x: Int,_ y: Int) {
        self.x = x
        self.y = y
    }
}

func sign(_ n: Int) -> Int {
    if n == 0 {
        return 0
    }
    return n > 0 ? 1 : -1
}

func + (lhs: Vec2, rhs: Vec2) -> Vec2 {
    return Vec2(lhs.x + rhs.x, lhs.y + rhs.y)
}
func - (lhs: Vec2, rhs: Vec2) -> Vec2 {
    return Vec2(lhs.x - rhs.x, lhs.y - rhs.y)
}
