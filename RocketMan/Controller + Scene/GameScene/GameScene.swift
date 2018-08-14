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
  var shieldEnergyDisplay: EnergyDisplay!
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
    
    // temp for now, will need to tap to start game eventually
    player.createPlume()
    thrusting = true
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
    shieldEnergyDisplay = EnergyDisplay(withColor: .blue)
    shieldEnergyDisplay.zPosition = 0
    shieldEnergyDisplay.position = CGPoint(x: 5, y: 5)
    addChild(shieldEnergyDisplay)
  }
  
  func thrust() {
    background.thrust()
  }
  
  func stopThrust() {
    background.stopThrust()
  }
  
  func setEnergy(to amount: Double) {
    self.shieldEnergyDisplay.setEnergy(to: amount)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    player.activateShields()
    //    player.createPlume()
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    player.deactivateShields()
    //    player.removePlume()
  }
  
}
