//
//  Hill.swift
//  AoC 2022
//
//  Created by En David on 18/11/2023.
//

import Foundation

class Hill {
    let image: SimpleImage
    let start: Coord2D
    let end: Coord2D
    
    var shortest: SimpleImage
    
    var stepsShortest: Int {
        get {
            return shortest.getValue(end)
        }
    }
    
    func climb(from s: Coord2D, steps: Int = 0) {
        if steps >= shortest.getValue(s) {
            // dynamic programming
            return
        }
        shortest.setValue(steps, at: s)
        if s == end {
            return
        }
        let height = image.getValue(s)
        let neighbors = image.get4Neighbors(s)
        for n in neighbors {
            let hn = image.getValue(n)
            if hn > height + 1 {
                continue
            }
            climb(from: n, steps: steps + 1)
        }
    }
    
    func descend(from e: Coord2D, steps: Int = 0) {
        // gradient descent
        let v = shortest.getValue(e)
        if v <= steps {
            return
        }
        shortest.setValue(steps, at: e)
        let height = image.getValue(e)
        if height == 0 {
            return
        }
        let neighbors = image.get4Neighbors(e)
        for n in neighbors {
            let hn = image.getValue(n)
            if hn < height - 1 {
                continue
            }
            descend(from: n, steps: steps + 1)
        }
    }
    
    init(lines: [String]) {
        let height = lines.count
        let width = lines.first?.count ?? 0
        let a = Character("a").asciiValue!
        let data = lines.flatMap { $0.compactMap { c in
            if c == "S" {
                return 0
            }
            if c == "E" {
                return 25
            }
            return Int(c.asciiValue! - a)
        }}
        image = SimpleImage(width: width, height: height, data: data)
        shortest = SimpleImage(width: width, height: height, value: Int.max)
        var S = Coord2D(-1, -1)
        var E = Coord2D(-1, -1)
        for y in 0..<lines.count {
            let line = lines[y]
            for x in 0..<width {
                let i = line.index(from: x)
                if line[i] == "S" {
                    S = (x, y)
                } else if line[i] == "E" {
                    E = (x, y)
                }
            }
        }
        start = S
        end = E
    }
}
