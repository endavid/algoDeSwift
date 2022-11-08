//
//  volume.swift
//  AoC 2015
//
//  Created by En David on 08/11/2022.
//

import Foundation

struct BoxVolume: CustomStringConvertible {
    var description: String {
        get {
            return "\(length)x\(width)x\(height)"
        }
    }
    let length: Int
    let width: Int
    let height: Int
    
    var surfaceArea: Int {
        get {
            return 2 * length * width + 2 * width * height + 2 * height * length
        }
    }
    
    var smallestSideArea: Int {
        get {
            return min(length * width, width * height, height * length)
        }
    }
    
    var smallestPerimeter: Int {
        get {
            return 2 * min(length + width, width + height, height + length)
        }
    }
    
    var volume: Int {
        get {
            return length * width * height
        }
    }
    
    init(_ s: String) {
        let numbers = s.split(separator: "x").compactMap { Int($0) }
        length = numbers[0]
        width = numbers[1]
        height = numbers[2]
    }
}
