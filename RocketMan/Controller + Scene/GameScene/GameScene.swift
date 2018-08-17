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

enum CollisionTypes: UInt32 {
  case player = 1
  case edge = 2
  case asteroid = 4
}

class GameScene: SKScene, UIRocketDelegate, SKPhysicsContactDelegate {
  
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
    let leftX: CGFloat = 0
    let rightX: CGFloat = self.size.width
    return (left: leftX, right: rightX)
  }
  
  override func didMove(to view: SKView) {
    createBackground()
    createPlayer()
    createEnergyDisplay()
    createBoundaries()
    motionManager = CMMotionManager()
    motionManager.startAccelerometerUpdates()
    
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    // temp for now, will need to tap to start game eventually
    player.createPlume()
    thrusting = true
    createAsteroid()
  }
  
  override func update(_ currentTime: TimeInterval) {
    super.update(currentTime)
    #if targetEnvironment(simulator)
    print("no tilting in simulator, try this on a device")
    #else
    if let accelerometerData = motionManager.accelerometerData {
      player.physicsBody?.applyImpulse(CGVector(dx: accelerometerData.acceleration.x * 10, dy: 0.0))
    }
    #endif
  }
  
  func createAsteroid() {
    let asteroid = Asteroid()
    asteroid.position = CGPoint(x: frame.midX, y: frame.midY)
    addChild(asteroid)
  }
  
  func createPlayer() {
    player = RocketNode()
    player.zPosition = 10
    player.position = CGPoint(x: frame.midX, y: frame.midY - player.size.height)
    player.uiDelegate = self
    player.name = "player"
    addChild(player)
    
    player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
    player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
    player.physicsBody!.isDynamic = true
    player.physicsBody?.allowsRotation = false
    player.physicsBody?.restitution = 0
    player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
    player.physicsBody?.collisionBitMask = CollisionTypes.asteroid.rawValue | CollisionTypes.edge.rawValue
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
  
  func createBoundaries() {
    self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    self.physicsBody?.restitution = 0
    self.physicsBody?.categoryBitMask = CollisionTypes.edge.rawValue
    self.physicsBody?.collisionBitMask = CollisionTypes.player.rawValue
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
  
  func didBegin(_ contact: SKPhysicsContact) {
    
  }
  
}
