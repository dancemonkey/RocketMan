//
//  GameScene.swift
//  RocketMan
//
//  Created by Drew Lanning on 8/10/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  var player: RocketNode!
  var exhaustPlume: SKEmitterNode?
  var background: SKTileMapNode!
  var thrusting: Bool = false {
    didSet {
      if thrusting {
        background.thrust()
      } else {
        background.stopThrust()
      }
    }
  }

  override func didMove(to view: SKView) {
    createPlayer()
    createBackground()
    
  }
  
  func createPlayer() {
    player = RocketNode()
    player.zPosition = 10
    player.position = CGPoint(x: frame.midX, y: frame.midY)
    addChild(player)
    
//    player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size())
//    player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
//    player.physicsBody?.isDynamic = false
//    player.physicsBody?.collisionBitMask = 0
  }
  
  func createBackground() {
    guard let spaceBg = childNode(withName: "starBackground") as? SKTileMapNode else {
      fatalError("background not loaded")
    }
    self.background = spaceBg
    background.zPosition = -30
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    player.createPlume()
    thrusting = true
//    createPlume()
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    player.removePlume()
    thrusting = false
//    removePlume()
  }
  
}
