//
//  RocketNode.swift
//  RocketMan
//
//  Created by Drew Lanning on 8/11/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit
import SpriteKit

class RocketNode: SKSpriteNode {
  
  private var _exhaustPlume: SKEmitterNode?
  private var _thrusterAudio: SKAudioNode?
  private var _energyLevel: Double = 100
  var energyLevel: Double {
    return _energyLevel
  }
  private var _velocity: Double?
  private var _thrusting: Bool = false {
    didSet {
      if _thrusting {
        let consume = SKAction.run {
          if self._energyLevel > 0 {
            self._energyLevel = self._energyLevel - 1
          } else {
            self._energyLevel = 0
          }
          self.uiDelegate?.setEnergy(to: self._energyLevel)
        }
        let wait = SKAction.wait(forDuration: 1)
        let sequence = SKAction.sequence([wait, consume])
        let runForever = SKAction.repeatForever(sequence)
        self.run(runForever, withKey: "consumingEnergy")
      } else {
        if self.action(forKey: "consumingEnergy") != nil {
          self.removeAction(forKey: "consumingEnergy")
        }
      }
      
    }
  }
  weak var uiDelegate: UIRocketDelegate?
  
  init() {
    let playerTexture = SKTexture(imageNamed: "player")
    let originalSize = playerTexture.size()
    let newSize = CGSize(width: originalSize.width/2, height: originalSize.height/2)
    super.init(texture: playerTexture, color: .clear, size: newSize)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setVelocity(to vel: Double) {
    self._velocity = vel
  }
  
  func createPlume() {
    self._thrusting = true
    if let plume = SKEmitterNode(fileNamed: "exhaust") {
      _exhaustPlume = plume
      _exhaustPlume!.position.y = plume.position.y - ((self.size.height/2) + 15)
      _exhaustPlume?.zPosition = 11
      addChild(_exhaustPlume!)
    }
    if let soundURL = Bundle.main.url(forResource: "thrust", withExtension: "m4a") {
      _thrusterAudio = SKAudioNode(url: soundURL)
      addChild(_thrusterAudio!)
    }
  }
  
  func removePlume() {
    self._thrusting = false
    if _exhaustPlume != nil {
      _exhaustPlume?.removeFromParent()
    }
    if _thrusterAudio != nil {
      _thrusterAudio?.removeFromParent()
    }
  }
  
}
