//
//  coordinates.swift
//  AoC 2015
//
//  Created by En David on 08/11/2022.
//

import Foundation

typealias Coord2D = (x: Int, y: Int)

func toIndex(coord: Coord2D, width: Int) -> Int {
    return coord.y * width + coord.x
}

func updatePosition(coord: Coord2D, direction: Character) -> Coord2D {
    switch(direction) {
    case "^":
        return Coord2D(coord.x, coord.y + 1)
    case "v":
        return Coord2D(coord.x, coord.y - 1)
    case ">":
        return Coord2D(coord.x + 1, coord.y)
    case "<":
        return Coord2D(coord.x - 1, coord.y)
    default:
        print("Unknown direction")
        return coord
    }
}
