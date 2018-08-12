//
//  EnergyDisplay.swift
//  RocketMan
//
//  Created by Drew Lanning on 8/12/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit
import SpriteKit

class EnergyDisplay: SKSpriteNode {

  private var energyLevel: Double = 100
  var currentEnergy: Double {
    return energyLevel
  }
  private var energyBar: SKShapeNode?
  
  init() {
    let outerRect = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 22, height: 102), cornerRadius: 4.0)
    outerRect.strokeColor = .white
    energyBar = SKShapeNode(rect: CGRect(x: 2, y: 2, width: 18, height: energyLevel), cornerRadius: 4.0)
    energyBar?.fillColor = .red
    super.init(texture: nil, color: .clear, size: CGSize(width: 20, height: 100))
    self.addChild(outerRect)
    self.addChild(energyBar!)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setEnergy(to level: Double) {
    self.energyLevel = level
    self.energyBar?.yScale = CGFloat(energyLevel/100)
  }
  
  func reduceEnergy(by level: Double) {
    
  }
  
  func raiseEnergy(by level: Double) {
    
  }
  
}
