//
//  Math.swift
//  FluidDynamicsCmd
//
//  Created by David Gavilan Ruiz on 25/02/2025.
//

func clamp<T: Comparable>(_ value: T, _ min: T, _ max: T) -> T {
    return value < min ? min : value > max ? max : value
}

func sign(_ x: Double) -> Double {
    return x < 0 ? -1 : 1
}
