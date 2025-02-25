//
//  Vec2.swift
//  FluidDynamicsCmd
//
//  Created by David Gavilan Ruiz on 25/02/2025.
//

struct Vec2<T: Numeric>: CustomStringConvertible {
    let x: T
    let y: T
    
    init(_ x: T, _ y: T) {
        self.x = x
        self.y = y
    }
    
    var description: String {
        get {
            return "(\(x), \(y))"
        }
    }
}
