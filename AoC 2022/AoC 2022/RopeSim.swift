//
//  RopeSim.swift
//  AoC 2022
//
//  Created by En David on 07/01/2023.
//

import Foundation

class RopeSim {
    enum Direction: String {
        case up = "U"
        case down = "D"
        case left = "L"
        case right = "R"
    }
    
    var rope: [Vec2]
    var visited: [Vec2: Int]
    var topLeft: Vec2 = .zero
    var bottomRight: Vec2 = .zero
    
    func updateTail(a: Int, b: Int) -> Bool {
        let head = rope[a]
        let tail = rope[b]
        let dx = head.x - tail.x
        let dy = head.y - tail.y
        if abs(dx) > 1 || abs(dy) > 1 {
            rope[b] = Vec2(tail.x + sign(dx), tail.y + sign(dy))
            return true
        }
        return false
    }
    
    func updateBoundingBox(_ c: Vec2) {
        // this function is only useful for visualization
        if c.x > bottomRight.x {
            bottomRight = Vec2(c.x, bottomRight.y)
        }
        if c.x < topLeft.x {
            topLeft = Vec2(c.x, topLeft.y)
        }
        if c.y > bottomRight.y {
            bottomRight = Vec2(bottomRight.x, c.y)
        }
        if c.y < topLeft.y {
            topLeft = Vec2(topLeft.x, c.y)
        }
    }
    
    func move(_ instruction: String) {
        let args = instruction.split(separator: " ")
        let dir = Direction(rawValue: String(args[0]))!
        let count = Int(args[1])!
        for _ in 0..<count {
            let head = rope.first!
            updateBoundingBox(head)
            switch(dir) {
            case .up:
                rope[0] = Vec2(head.x, head.y + 1)
            case .down:
                rope[0] = Vec2(head.x, head.y - 1)
            case .left:
                rope[0] = Vec2(head.x - 1, head.y)
            case .right:
                rope[0] = Vec2(head.x + 1, head.y)
            }
            for i in 1..<rope.count {
                if !updateTail(a: i-1, b: i) {
                    break
                }
                if i == rope.count - 1 {
                    visited[rope.last!, default: 0] += 1
                }
            }
        }
    }
    
    init(ropeLength: Int = 2) {
        rope = [Vec2].init(repeating: .zero, count: ropeLength)
        visited = [.zero: 1]
    }
}
