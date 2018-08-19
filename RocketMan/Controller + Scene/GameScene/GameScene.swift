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
  var asteroids = [Asteroid]()
  
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
    startAsteroidBelt()
  }
  
  override func update(_ currentTime: TimeInterval) {
    super.update(currentTime)
    
    for (index, asteroid) in asteroids.enumerated() {
      asteroid.lifetime = asteroid.lifetime + 1
      if asteroidOutOfBounds(asteroid) && asteroid.lifetime > asteroid.minLifetime {
        asteroid.removeFromParent()
        asteroids.remove(at: index)
      }
    }
    
    #if targetEnvironment(simulator)
    print("no tilting in simulator, try this on a device")
    #else
    if let accelerometerData = motionManager.accelerometerData {
      player.physicsBody?.applyImpulse(CGVector(dx: accelerometerData.acceleration.x * 10, dy: 0.0))
    }
    #endif
  }
  
  func startAsteroidBelt() {
    let create = SKAction.run {
      let xRand = GKRandomDistribution(lowestValue: 0, highestValue: Int(self.frame.width))
      self.createAsteroid(at: CGPoint(x: xRand.nextInt(), y: Int(self.frame.height + 100)))
    }
    let randomCreate = GKRandomDistribution(forDieWithSideCount: 6)
    let wait = SKAction.wait(forDuration: TimeInterval(randomCreate.nextInt()))
    let sequence = SKAction.sequence([create, wait])
    let repeatForever = SKAction.repeatForever(sequence)
    run(repeatForever)
  }
  
  func createAsteroid(at point: CGPoint) {
    let asteroid = Asteroid()
    asteroid.position = point
    asteroid.zPosition = -10
    addChild(asteroid)
    asteroids.append(asteroid)
    asteroid.physicsBody?.applyImpulse(asteroid.randomVector())
  }
  
  func createPlayer() {
    player = RocketNode()
    player.zPosition = 10
    player.position = CGPoint(x: frame.midX, y: frame.midY - player.size.height)
    player.uiDelegate = self
    player.name = "player"
    let constraint = SKConstraint.positionY(SKRange(lowerLimit: frame.midY - player.size.height, upperLimit: frame.midY - player.size.height))
    player.constraints = [constraint]
    addChild(player)
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
    self.name = "border"
  }
  
  func asteroidOutOfBounds(_ asteroid: Asteroid) -> Bool {
    if self.intersects(asteroid) {
      return false
    } else {
      return true
    }
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
  
  func destroyRocket() {
    print("rocket destroyed")
    if let explosion = SKEmitterNode(fileNamed: "explosion") {
      explosion.position = player.position
      player.removePlume()
      player.removeAllActions()
      player.removeFromParent()
      addChild(explosion)
    }
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    
    if contact.bodyA.node == player || contact.bodyB.node == player {
      if contact.bodyA.node?.name == "border" || contact.bodyB.node?.name == "border" {
        return
      }
      if contact.bodyA.node == player {
        player.impact(by: contact.bodyB.node! as! Asteroid)
      } else {
        player.impact(by: contact.bodyA.node! as! Asteroid)
      }
    } else {
      return
    }
  }
  
}
