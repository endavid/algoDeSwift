//
//  color.swift
//  AoC 2015
//
//  Created by En David on 29/11/2022.
//

import Foundation

typealias Palette = [Color]

struct Color {
    static let blackAndWhitePalette: Palette = [
        Color(hexValue: 0x000000),
        Color(hexValue: 0xffffff)
    ]
    
    static func grayScale(maxValue: Int) -> Palette {
        return (0...maxValue).map {
            let c = 255 * $0 / maxValue
            return Color(r: c, g: c, b: c)
        }
    }
    
    let r: Int
    let g: Int
    let b: Int
    
    init(r: Int, g: Int, b: Int) {
        self.r = r
        self.g = g
        self.b = b
    }
    
    init(hexValue: Int) {
        // 0xff0014 => red: 255, green: 0, blue: 20
        r = (hexValue >> 16) & 0xff
        g = (hexValue >> 8) & 0xff
        b = hexValue & 0xff
    }
}
