//
//  AABB.swift
//  AoC 2023
//
//  Created by David Gavilan Ruiz on 03/03/2024.
//

import Foundation

/// Axis-Aligned Bounding Box
struct AABB<T: SignedNumeric> {
    var x0: T
    var y0: T
    var z0: T
    var x1: T
    var y1: T
    var z1: T
    
    mutating func moveDown() {
        y0 -= 1
        y1 -= 1
    }
}
