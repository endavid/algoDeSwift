//
//  BoxedVelocityField.swift
//  FluidDynamicsCmd
//
//  Created by David Gavilan Ruiz on 25/02/2025.
//

/// Naive implementation of fluid in a box
/// from "Real-Time Fluid Dynamics for Games", GDC 2003
class BoxedVelocityField {
    let n: Int // box size
    var dt: Double = 1.0 / 30.0 // 30 fps
    var diffusionFactor: Double = 0.01
    var field: [Axis: SimpleImage<Double>]
    
    func get(_ i: Int, _ j: Int) -> Vec2<Double> {
        let x = field[.x]!.get(i, j)
        let y = field[.y]!.get(i, j)
        return Vec2(x, y)
    }
    
    // MARK: Add sources
    
    func addOmni(magnitude: Double, center: Coord2D, radius: Int) {
        let rangex = max(0, center.x - radius)...min(center.x + radius, n + 1)
        let rangey = max(0, center.y - radius)...min(center.y + radius, n + 1)
        for i in rangex {
            let x = Double(i - center.x) / Double(radius)
            for j in rangey {
                let y = Double(j - center.y) / Double(radius)
                if x * x + y * y > 1 {
                    // outside the circle
                    continue
                }
                var r = max(abs(x), abs(y))
                if r == 0 {
                    r = 1
                }
                // cos = x / r; sin = y / r
                field[.x]!.addValue(magnitude * x / r, at: (i,j))
                field[.y]!.addValue(magnitude * y / r, at: (i,j))
            }
        }
    }
    
    init(n: Int) {
        self.n = n
        // size is (n+2) because we add boundaries
        let image = SimpleImage<Double>(width: n + 2, height: n + 2, value: 0)
        field = [.x: image, .y: image]
    }
}
