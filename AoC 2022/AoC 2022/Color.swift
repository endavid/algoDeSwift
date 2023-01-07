//
//  Color.swift
//  AoC 2022
//
//  Created by En David on 10/12/2022.
//

import Foundation

typealias Palette = [Color]

struct Color {
    static let blackAndWhitePalette: Palette = [
        Color(hexValue: 0x000000),
        Color(hexValue: 0xffffff)
    ]
    
    static let brownToGreenPalette: Palette = [
        Color(hexValue: 0x3B270B),
        Color(hexValue: 0x533F1D),
        Color(hexValue: 0x6F562D),
        Color(hexValue: 0x6F6326),
        Color(hexValue: 0x6B6F23),
        Color(hexValue: 0x7A812D),
        Color(hexValue: 0x77912C),
        Color(hexValue: 0x7EA23E),
        Color(hexValue: 0x75AE3C),
        Color(hexValue: 0x67C926)
    ]
    
    static func grayScale(maxValue: Int) -> Palette {
        return (0...maxValue).map {
            let c = 255 * $0 / maxValue
            return Color(r: c, g: c, b: c)
        }
    }
    
    static func redToYellow(maxValue: Int) -> Palette {
        return (0...maxValue).map {
            let r = 128 + 127 * $0 / maxValue
            let g = 255 * $0 / maxValue
            return Color(r: r, g: g, b: 0)
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
