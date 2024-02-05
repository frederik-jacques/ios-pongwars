//
//  CGVector+Normalize.swift
//  PongWars
//
//  Created by Frederik Jacques on 04/02/2024.
//

import Foundation

extension CGVector {

    func normalize() -> CGVector {
        let length = sqrt(dx * dx + dy * dy)
        return CGVector(dx: dx / length, dy: dy / length)
    }
    
}
