//
//  VoxelVolume.swift
//  AoC 2023
//
//  Created by David Gavilan Ruiz on 03/03/2024.
//

import Foundation

struct VoxelVolume<T: SignedNumeric & Hashable> {
    let width: Int
    let depth: Int
    let height: Int
    var data: [T]
    
    func index(x: Int, y: Int, z: Int) -> Int {
        return y * width * depth + z * width + x
    }
    
    mutating func place(_ v: T, in aabb: AABB<Int>) {
        for y in aabb.y0...aabb.y1 {
            for x in aabb.x0...aabb.x1 {
                for z in aabb.z0...aabb.z1 {
                    data[index(x: x, y: y, z: z)] = v
                }
            }
        }
    }
    
    mutating func remove(aabb: AABB<Int>) {
        place(0, in: aabb)
    }
    
    func collisionBelow(aabb: AABB<Int>) -> Set<T> {
        let y = aabb.y0 - 1
        if y == 0 {
            return [0]
        }
        var colliders: Set<T> = []
        for x in aabb.x0...aabb.x1 {
            for z in aabb.z0...aabb.z1 {
                let c = data[index(x: x, y: y, z: z)]
                if c != 0 {
                    colliders.insert(c)
                }
            }
        }
        return colliders
    }
    
    init(width: Int, depth: Int, height: Int) {
        self.width = width
        self.depth = depth
        self.height = height
        self.data = [T].init(repeating: 0, count: width * depth * height)
    }
    
    func dumpRow(y: Int) {
        let i = index(x: 0, y: y, z: 0)
        let row = Array(data[i..<(i+width*depth)])
        let chunks = row.chunked(into: width)
        chunks.forEach { print($0) }
    }
    
    func dump() {
        for y in (0..<height).reversed() {
            print("row \(y):")
            dumpRow(y: y)
        }
    }
}

