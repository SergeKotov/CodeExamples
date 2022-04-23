//
//  Randoms.swift
//  Math
//
//  Created by Serge Kotov on 22.03.2022.
//

import SpriteKit

/// Return true for given probability in range 0...1
/// - Parameter r: chance from 0.0 to 1.0
/// - Returns: true, if a random value included in range from 0 to r,
/// otherwise returns false
func chance(_ r: Float) -> Bool {
    guard r > 0 else { return false }
    guard r < 1 else { return true }
    
    let c = Float.random(in: 0...1)
    return c < r ? true : false
}

/// Return random floating value: multiplier or -multiplier
/// - Parameter multiplier: Double, Float, CGFloat value
/// - Returns: positive or negative multiplier value
func randomBool<T: BinaryFloatingPoint>(_ multiplier: T = 1.0) -> T {
    let value: T = Bool.random() ? 1 : -1
    return value * multiplier
}
