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
    var viscosity: Double = 0.1
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
    
    // MARK: Solvers
    
    private func diffuse(axis: Axis) {
        let x0 = field[axis]!
        let iterations = 20
        let a = viscosity * dt * Double(n * n)
        for _ in 0..<iterations {
            for i in 1...n {
                for j in 1...n {
                    let sum = field[axis]!.get4NeighborValues((i,j)).reduce(0, +)
                    let v = (x0.get(i, j) + a * sum) / (1 + 4 * a)
                    field[axis]!.setValue(v, at: (i,j))
                }
            }
            applyBoundaryConditions(axis: axis)
        }
    }
    
    private func advect(axis: Axis, velocity: BoxedVelocityField) {
        let d0 = field[axis]!
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
                field[axis]!.setValue(a + b, at: (i,j))
            }
        }
        applyBoundaryConditions(axis: axis)
    }
    
    private func applyBoundaryConditions(axis: Axis, sa: Double? = nil, sb: Double? = nil) {
        let signA = sa ?? (axis == .x ? -1.0 : 1.0)
        let signB = sb ?? (axis == .y ? -1.0 : 1.0)
        for i in 1...n {
            field[axis]!.setValue(signA * field[axis]!.get(1,i), at: (0,i))
            field[axis]!.setValue(signA * field[axis]!.get(n,i), at: (n+1,i))
            field[axis]!.setValue(signB * field[axis]!.get(i,1), at: (i,0))
            field[axis]!.setValue(signB * field[axis]!.get(i,n), at: (i,n+1))
        }
        field[axis]!.setValue(0.5 * (field[axis]!.get(1,0) + field[axis]!.get(0,1)), at: (0,0))
        field[axis]!.setValue(0.5 * (field[axis]!.get(1,n+1) + field[axis]!.get(0,n)), at: (0,n+1))
        field[axis]!.setValue(0.5 * (field[axis]!.get(n,0) + field[axis]!.get(n+1,1)), at: (n+1,0))
        field[axis]!.setValue(0.5 * (field[axis]!.get(n,n+1) + field[axis]!.get(n+1,n)), at: (n+1,n+1))
    }
    
    private func project(_ vfCopy: BoxedVelocityField) {
        /*
         void project ( int N, float * u, float * v, float * p, float * div )
         {
         int i, j, k;
         float h;
         h = 1.0/N;
         for ( i=1 ; i<=N ; i++ ) {
         for ( j=1 ; j<=N ; j++ ) {
         div[IX(i,j)] = -0.5*h*(u[IX(i+1,j)]-u[IX(i-1,j)]+
         v[IX(i,j+1)]-v[IX(i,j-1)]);
         p[IX(i,j)] = 0;
         }
         }
         set_bnd ( N, 0, div ); set_bnd ( N, 0, p );
         for ( k=0 ; k<20 ; k++ ) {
         for ( i=1 ; i<=N ; i++ ) {
         for ( j=1 ; j<=N ; j++ ) {
         p[IX(i,j)] = (div[IX(i,j)]+p[IX(i-1,j)]+p[IX(i+1,j)]+p[IX(i,j-1)]+p[IX(i,j+1)])/4;
         }
         }
         set_bnd ( N, 0, p );
         }
         for ( i=1 ; i<=N ; i++ ) {
         for ( j=1 ; j<=N ; j++ ) {
         u[IX(i,j)] -= 0.5*(p[IX(i+1,j)]-p[IX(i-1,j)])/h;
         v[IX(i,j)] -= 0.5*(p[IX(i,j+1)]-p[IX(i,j-1)])/h;
         }
         }
         set_bnd ( N, 1, u ); set_bnd ( N, 2, v );
         }
         */
        let h = 1.0 / Double(n)
        for i in 1...n {
            for j in 1...n {
                let div = -0.5 * h * (field[.x]!.get(i+1, j) - field[.x]!.get(i-1, j) + field[.y]!.get(i,j+1) - field[.y]!.get(i,j-1))
                vfCopy.field[.y]!.setValue(div, at: (i,j))
                vfCopy.field[.x]!.setValue(0, at: (i,j))
            }
        }
        vfCopy.applyBoundaryConditions(axis: .y, sa: 1.0, sb: 1.0)
        vfCopy.applyBoundaryConditions(axis: .x, sa: 1.0, sb: 1.0)
        let iterations = 20
        for _ in 0..<iterations {
            for i in 1...n {
                for j in 1...n {
                    let p = vfCopy.field[.y]!.get(i,j) + vfCopy.field[.x]!.get(i-1,j) + vfCopy.field[.x]!.get(i+1,j) + vfCopy.field[.x]!.get(i,j-1) + vfCopy.field[.x]!.get(i,j+1)
                    vfCopy.field[.x]!.setValue(p/4.0, at: (i,j))
                }
            }
            vfCopy.applyBoundaryConditions(axis: .x, sa: 1.0, sb: 1.0)
        }
        for i in 1...n {
            for j in 1...n {
                let u = vfCopy.field[.x]!.get(i+1,j) - vfCopy.field[.x]!.get(i-1,j)
                let v = vfCopy.field[.x]!.get(i,j+1) - vfCopy.field[.x]!.get(i,j-1)
                field[.x]!.addValue(-0.5 * u * Double(n), at: (i,j))
                field[.y]!.addValue(-0.5 * v * Double(n), at: (i,j))
            }
        }
        applyBoundaryConditions(axis: .x)
        applyBoundaryConditions(axis: .y)
    }
    
    func diffuse() {
        diffuse(axis: .x)
        diffuse(axis: .y)
    }
    
    func advect() {
        let vfCopy = copy()
        advect(axis: .x, velocity: vfCopy)
        advect(axis: .y, velocity: vfCopy)
    }
    
    func step() {
        diffuse()
        project(copy())
        let vfCopy = copy()
        advect()
        project(vfCopy)
    }
    
    private func copy() -> BoxedVelocityField {
        let vf = BoxedVelocityField(n: n)
        for (k,image) in field {
            vf.field[k] = image
        }
        vf.dt = dt
        vf.viscosity = viscosity
        return vf
    }
    
    init(n: Int) {
        self.n = n
        // size is (n+2) because we add boundaries
        let image = SimpleImage<Double>(width: n + 2, height: n + 2, value: 0)
        field = [.x: image, .y: image]
    }
}
