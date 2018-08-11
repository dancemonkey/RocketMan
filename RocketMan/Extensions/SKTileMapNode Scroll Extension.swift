//
//  BackgroundNode.swift
//  RocketMan
//
//  Created by Drew Lanning on 8/11/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit
import SpriteKit

extension SKTileMapNode {
  
  func thrust() {
    let moveDown = SKAction.moveBy(x: 0.0, y: -self.tileSize.height, duration: 0.5)
    let moveReset = SKAction.moveBy(x: 0.0, y: self.tileSize.height, duration: 0)
    let moveLoop = SKAction.sequence([moveDown, moveReset])
    let moveForever = SKAction.repeatForever(moveLoop)
    self.run(moveForever, withKey: "thrusting")
  }
  
  func stopThrust() {
    if let thrusting = self.action(forKey: "thrusting") {
      let slow = SKAction.speed(to: 0.0, duration: 1.0)
      let stop = SKAction.run {
        self.removeAllActions()
        self.speed = 1.0
      }
      let sequence = SKAction.sequence([slow, stop])
      self.run(sequence)
    }
  }
  
}
