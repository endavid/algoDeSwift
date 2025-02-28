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
    
    func advect(velocity: BoxedVelocityField) {
        let d0 = image
        let dt0 = dt * Double(n)
        for i in 1...n {
            for j in 1...n {
                let v = velocity.get(i, j)
                let x = clamp(Double(i) - dt0 * v.x, 0.5, Double(n)+0.5)
                let y = clamp(Double(j) - dt0 * v.y, 0.5, Double(n)+0.5)
                let i0 = Int(x)
                let i1 = i0 + 1
                let j0 = Int(y)
                let j1 = j0 + 1
                let s1 = x - Double(i0)
                let s0 = 1 - s1
                let t1 = y - Double(j0)
                let t0 = 1 - t1
                let a = s0*(t0*d0.get(i0,j0)+t1*d0.get(i0,j1))
                let b = s1*(t0*d0.get(i1,j0)+t1*d0.get(i1,j1))
                image.setValue(a + b, at: (i,j))
            }
        }
        applyBoundaryConditions()
    }
    
    func advectForward(velocity: BoxedVelocityField) {
        let d0 = image
        let dt0 = dt * Double(n)
        
        for i in 1...n {
            for j in 1...n {
                let v = velocity.get(i, j)
                
                // Compute forward position
                let x = clamp(Double(i) + dt0 * v.x, 0.5, Double(n) + 0.5)
                let y = clamp(Double(j) + dt0 * v.y, 0.5, Double(n) + 0.5)
                
                let i0 = Int(x)
                let i1 = i0 + 1
                let j0 = Int(y)
                let j1 = j0 + 1
                
                let s1 = x - Double(i0)
                let s0 = 1 - s1
                let t1 = y - Double(j0)
                let t0 = 1 - t1
                
                let a = s0 * (t0 * d0.get(i0, j0) + t1 * d0.get(i0, j1))
                let b = s1 * (t0 * d0.get(i1, j0) + t1 * d0.get(i1, j1))

                // Instead of setting at (i,j), distribute to (i0, j0), (i0, j1), (i1, j0), (i1, j1)
                image.addValue((a + b) * 0.25, at: (i0, j0))
                image.addValue((a + b) * 0.25, at: (i0, j1))
                image.addValue((a + b) * 0.25, at: (i1, j0))
                image.addValue((a + b) * 0.25, at: (i1, j1))
            }
        }
                
        applyBoundaryConditions()
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
