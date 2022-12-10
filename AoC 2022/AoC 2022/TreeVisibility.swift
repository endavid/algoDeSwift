//
//  TreeVisibility.swift
//  AoC 2022
//
//  Created by En David on 10/12/2022.
//

import Foundation

func computeTreeVisibility(from img: SimpleImage) -> SimpleImage {
    var out = SimpleImage(width: img.width, height: img.height, value: 1)
    for x in 1..<(img.width-1) {
        for y in 1..<(img.height-1) {
            let c = (x, y)
            let treeHeight = img.getValue(c)
            let treeLines = img.getNeighborValuesToEdges(c)
            let visibles = treeLines.map { line in
                line.reduce(true, { $0 && $1 < treeHeight })
            }
            let isVisible = visibles.reduce(false, {$0 || $1})
            if !isVisible {
                out.setValue(0, at: c)
            }
        }
    }
    return out
}

func computeScenicScore(from img: SimpleImage) -> SimpleImage {
    var out = SimpleImage(width: img.width, height: img.height, value: 1)
    for x in 0..<img.width {
        for y in 0..<img.height {
            let c = (x, y)
            let treeHeight = img.getValue(c)
            let treeLines = img.getNeighborValuesToEdges(c)
            let distances = treeLines.map { line in
                var d = 0
                let l = Array(line)
                while d < l.count {
                    if l[d] >= treeHeight {
                        d += 1
                        break
                    }
                    d += 1
                }
                return d
            }
            let score = distances.reduce(1, *)
            out.setValue(score, at: c)
        }
    }
    return out
}
