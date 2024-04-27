//
//  Utility.swift
//  DeepDive
//
//  Created by Andrew Oroh on 27/04/24.
//

import Foundation

func getRandomString() -> String {
    let strings = [sharkRight1, sharkRight2, sharkLeft]
    let randomIndex = Int.random(in: 0..<strings.count)
    return strings[randomIndex]
}

func random() -> CGFloat {
  return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
  return random() * (max - min) + min
}
