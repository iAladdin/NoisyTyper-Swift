//
//  Number-extensions.swift
//  NoisyTyper
//
//  Created by Aladdin on 15/12/8.
//  Copyright © 2015年 Aladdin. All rights reserved.
//

import Foundation
public extension Float {
    public static func random(lower: Float = 0, _ upper: Float = 100) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
}
public extension Int {
    public static func random(lower: Int = 0, _ upper: Int = 100) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}