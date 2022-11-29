//
//  illumination.swift
//  AoC 2015
//
//  Created by En David on 28/11/2022.
//

import Foundation
import RegexBuilder

class Illumination {
    enum Action: String {
        case turnOn = "turn on"
        case turnOff = "turn off"
        case toggle = "toggle"
    }
    
    struct Instruction {
        let action: Action
        let topLeft: Coord2D
        let bottomRight: Coord2D
        init(_ s: String) throws {
            // sample string:
            //   turn off 660,55 through 986,197
            let captureInt = TryCapture {
                OneOrMore(.digit)
            } transform: { d in
                Int(d)
            }
            let regex = Regex {
                TryCapture {
                    ChoiceOf {
                        "turn off"
                        "turn on"
                        "toggle"
                    }
                } transform: { s in
                    Action(rawValue: String(s))
                }
                " "
                captureInt
                /\,/
                captureInt
                " through "
                captureInt
                /\,/
                captureInt
            }
            let o = try regex.wholeMatch(in: s)!.output
            action = o.1
            topLeft = Coord2D(o.2, o.3)
            bottomRight = Coord2D(o.4, o.5)
        }
    }
    
    var image: SimpleImage
    
    func apply(instruction i: Instruction) {
        for y in i.topLeft.y...i.bottomRight.y {
            for x in i.topLeft.x...i.bottomRight.x {
                let c = Coord2D(x, y)
                switch(i.action) {
                case .turnOn:
                    image.setValue(1, at: c)
                case .turnOff:
                    image.setValue(0, at: c)
                case .toggle:
                    let v = image.getValue(c)
                    image.setValue(1 - v, at: c)
                }
            }
        }
    }
    
    func applyAnalog(instruction i: Instruction) {
        for y in i.topLeft.y...i.bottomRight.y {
            for x in i.topLeft.x...i.bottomRight.x {
                let c = Coord2D(x, y)
                let v = image.getValue(c)
                switch(i.action) {
                case .turnOn:
                    image.setValue(v + 1, at: c)
                case .turnOff:
                    image.setValue(max(0, v - 1), at: c)
                case .toggle:
                    image.setValue(v + 2, at: c)
                }
            }
        }
    }
    
    init() {
        image = SimpleImage(width: 1000, height: 1000)
    }
}
