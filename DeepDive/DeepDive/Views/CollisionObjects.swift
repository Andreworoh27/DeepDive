//
//  CollisionObjects.swift
//  DeepDive
//
//  Created by Andrew Oroh on 27/04/24.
//

import Foundation

struct PhysicsCategory {
    static let none : UInt32 = 0
    static let all : UInt32 = UInt32.max
    static let player : UInt32 = 0b1
    static let shark : UInt32 = 0b10
    static let bomb: UInt32 = 0b100
}
