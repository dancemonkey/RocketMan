//
//  GameScene.swift
//  RocketMan
//
//  Created by Drew Lanning on 8/10/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

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
  var motionManager: CMMotionManager!
  var borderLimits: (left: CGFloat, right: CGFloat) {
    let leftX: CGFloat = player.size.width
    let rightX: CGFloat = self.size.width - leftX
    return (left: leftX, right: rightX)
  }
  
  override func didMove(to view: SKView) {
    createBackground()
    createPlayer()
    createEnergyDisplay()
    motionManager = CMMotionManager()
    motionManager.startAccelerometerUpdates()
    physicsWorld.gravity = .zero
    
    // temp for now, will need to tap to start game eventually
    player.createPlume()
    thrusting = true
  }
  
  override func update(_ currentTime: TimeInterval) {
    super.update(currentTime)
    #if targetEnvironment(simulator)
    print("no tilting in simulator, try this on a device")
    #else
    if let accelerometerData = motionManager.accelerometerData {
      physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.x * 5, dy: 0.0)
      if player.position.x <= borderLimits.left {
        player.position.x = borderLimits.left
      } else if player.position.x >= borderLimits.right {
        player.position.x = borderLimits.right
      }
    }
    #endif
  }
  
  func createPlayer() {
    player = RocketNode()
    player.zPosition = 10
    player.position = CGPoint(x: frame.midX, y: frame.midY - player.size.height)
    player.setVelocity(to: Double(background.tileSize.height))
    player.uiDelegate = self
    addChild(player)
    
    player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
    player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
    player.physicsBody?.isDynamic = true
    player.physicsBody?.collisionBitMask = 0
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
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    player.deactivateShields()
  }
  
}
