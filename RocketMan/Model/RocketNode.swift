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
  
  private var exhaustPlume: SKEmitterNode?
  private var thrusterAudio: SKAudioNode?
  private var energy: Double = 100
  var energyLevel: Double {
    return energy
  }
  private var velocity: Double?
  private var thrusting: Bool = false {
    didSet {
      if thrusting {
        let consume = SKAction.run {
          self.energy = self.energy - 1
          self.uiDelegate?.setEnergy(to: self.energy)
        }
        let wait = SKAction.wait(forDuration: 1)
        let sequence = SKAction.sequence([consume, wait])
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
    self.velocity = vel
  }
  
  func createPlume() {
    self.thrusting = true
    if let plume = SKEmitterNode(fileNamed: "exhaust") {
      exhaustPlume = plume
      exhaustPlume!.position.y = plume.position.y - ((self.size.height/2) + 15)
      exhaustPlume?.zPosition = 11
      addChild(exhaustPlume!)
    }
    if let soundURL = Bundle.main.url(forResource: "thrust", withExtension: "m4a") {
      thrusterAudio = SKAudioNode(url: soundURL)
      addChild(thrusterAudio!)
    }
  }
  
  func removePlume() {
    self.thrusting = false
    if exhaustPlume != nil {
      exhaustPlume?.removeFromParent()
    }
    if thrusterAudio != nil {
      thrusterAudio?.removeFromParent()
    }
  }
  
}
