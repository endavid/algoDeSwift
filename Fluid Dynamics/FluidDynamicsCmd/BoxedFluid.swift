//
//  BoxedFluid.swift
//  FluidDynamicsCmd
//
//  Created by David Gavilan Ruiz on 25/02/2025.
//

/// Naive implementation of fluid in a box
/// from "Real-Time Fluid Dynamics for Games", GDC 2003
class BoxedFluid {
    let n: Int // box size
    var dt: Double = 1.0 / 30.0 // 30 fps
    var diffusionFactor: Double = 0.01
    var image: SimpleImage<Double>
    
    // MARK: Add sources
    
    func addBox(_ v: Double, from a: Coord2D, to b: Coord2D) {
        image.drawBox(v, from: a, to: b)
    }
    
    // MARK: Solvers
    
    func diffuse() {
        let x0 = image
        let iterations = 20
        let a = diffusionFactor * dt * Double(n * n)
        for _ in 0..<iterations {
            for i in 1...n {
                for j in 1...n {
                    let sum = image.get4NeighborValues((i,j)).reduce(0, +)
                    let v = (x0.get(i, j) + a * sum) / (1 + 4 * a)
                    image.setValue(v, at: (i,j))
                }
            }
            applyBoundaryConditions()
        }
    }
    
    private func applyBoundaryConditions() {
        for i in 1...n {
            image.setValue(image.get(1,i), at: (0,i))
            image.setValue(image.get(n,i), at: (n+1,i))
            image.setValue(image.get(i,1), at: (i,0))
            image.setValue(image.get(i,n), at: (i,n+1))
        }
        image.setValue(0.5 * (image.get(1,0) + image.get(0,1)), at: (0,0))
        image.setValue(0.5 * (image.get(1,n+1) + image.get(0,n)), at: (0,n+1))
        image.setValue(0.5 * (image.get(n,0) + image.get(n+1,1)), at: (n+1,0))
        image.setValue(0.5 * (image.get(n,n+1) + image.get(n+1,n)), at: (n+1,n+1))
    }
    
    init(n: Int) {
        self.n = n
        // size is (n+2) because we add boundaries
        image = SimpleImage(width: n + 2, height: n + 2, value: 0)
    }
}
