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
  
  var exhaustPlume: SKEmitterNode?
  var thrusterAudio: SKAudioNode?
  
  init() {
    let playerTexture = SKTexture(imageNamed: "player")
    super.init(texture: playerTexture, color: .clear, size: playerTexture.size())
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func createPlume() {
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
    if exhaustPlume != nil {
      exhaustPlume?.removeFromParent()
    }
    if thrusterAudio != nil {
      thrusterAudio?.removeFromParent()
    }
  }
  
}
