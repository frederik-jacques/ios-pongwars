//
//  Comparable+Clamp.swift
//  PongWars
//
//  Created by Frederik Jacques on 04/02/2024.
//

import CoreGraphics

extension Comparable {
    
    func clamped(minimum: Self, maximum: Self) -> Self {
        return self < minimum ? minimum : (maximum < self ? maximum : self)
    }
    
}
