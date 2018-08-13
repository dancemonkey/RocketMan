//
//  GameScene.swift
//  RocketMan
//
//  Created by Drew Lanning on 8/10/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, UIRocketDelegate {
  
  var player: RocketNode!
  var energyDisplay: EnergyDisplay!
  var exhaustPlume: SKEmitterNode?
  var background: SKTileMapNode!
  var thrusting: Bool = false {
    didSet {
      if thrusting {
        thrust()
      } else {
        stopThrust()
      }
    }
  }

  override func didMove(to view: SKView) {
    createBackground()
    createPlayer()
    createEnergyDisplay()
  }
  
  func createPlayer() {
    player = RocketNode()
    player.zPosition = 10
    player.position = CGPoint(x: frame.midX, y: frame.midY)
    player.setVelocity(to: Double(background.tileSize.height))
    player.uiDelegate = self
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
  
  func createEnergyDisplay() {
    energyDisplay = EnergyDisplay()
    energyDisplay.zPosition = 0
    energyDisplay.position = CGPoint(x: 5, y: 5)
    addChild(energyDisplay)
  }
  
  func thrust() {
    background.thrust()
  }
  
  func stopThrust() {
    background.stopThrust()
  }
  
  func setEnergy(to amount: Double) {
    self.energyDisplay.setEnergy(to: amount)
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
