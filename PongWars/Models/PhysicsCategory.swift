//
//  PhysicsCategory.swift
//  PongWars
//
//  Created by Frederik Jacques on 04/02/2024.
//

import Foundation

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let ball1: UInt32 = 0x1 << 0
    static let ball2: UInt32 = 0x1 << 1
    static let tile1: UInt32 = 0x1 << 2
    static let tile2: UInt32 = 0x1 << 3
}
