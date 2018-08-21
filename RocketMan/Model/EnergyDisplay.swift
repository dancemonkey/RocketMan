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
  
  private var _lowEnergyThreshold: Double = 25
  private var _energyLevel: Double = 100 {
    willSet {
      if newValue < _lowEnergyThreshold && !_lowEnergyFlashing {
        _lowEnergyFlashing = true
      } else if newValue > _lowEnergyThreshold {
        _lowEnergyFlashing = false
      }
    }
  }
  var currentEnergy: Double {
    return _energyLevel
  }
  private var _energyBar: SKShapeNode?
  private var _outerRect: SKShapeNode!
  private var _lowEnergyFlashing: Bool = false {
    willSet {
      if newValue == true {
        startFlashing()
      } else {
        stopFlashing()
      }
    }
  }
  
  init(withColor color: UIColor) {
    _outerRect = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 22, height: 102), cornerRadius: 4.0)
    _outerRect.strokeColor = .white
    _energyBar = SKShapeNode(rect: CGRect(x: 2, y: 2, width: 18, height: _energyLevel), cornerRadius: 4.0)
    _energyBar?.fillColor = color
    super.init(texture: nil, color: .clear, size: CGSize(width: 20, height: 100))
    self.addChild(_outerRect)
    self.addChild(_energyBar!)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setEnergy(to level: Double) {
    if level >= 0 {
      self._energyLevel = level
      self._energyBar?.yScale = CGFloat(_energyLevel/100)
    } else {
      self._energyLevel = 0
      self._energyBar?.yScale = 0.0
    }
  }
  
  func startFlashing() {
    let originalColor = SKAction.run {
      self._outerRect.strokeColor = .white
    }
    let wait = SKAction.wait(forDuration: 0.25)
    let dangerColor = SKAction.run {
      self._outerRect.strokeColor = .red
    }
    let sequence = SKAction.sequence([dangerColor, wait, originalColor, wait])
    let repeatForever = SKAction.repeatForever(sequence)
    self._outerRect.run(repeatForever, withKey: Keys.lowEnergyFlashing.rawValue)
  }
  
  func stopFlashing() {
    if self._outerRect.action(forKey: Keys.lowEnergyFlashing.rawValue) != nil {
      self._outerRect.removeAction(forKey: Keys.lowEnergyFlashing.rawValue)
      self._outerRect.strokeColor = .white
    }
  }
  
}
