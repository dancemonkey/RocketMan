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
  var shieldsUp: Bool = false
  private var _shield: SKSpriteNode?
  private var _thrusterAudio: SKAudioNode?
  private var _shieldEnergyLevel: Double = 100 {
    didSet {
      if _shieldEnergyLevel >= 100 {
        stopRechargingShields()
        _shieldEnergyLevel = 100
      }
    }
  }
  var shieldEnergyLevel: Double {
    return _shieldEnergyLevel
  }
  private var _velocity: Double?
  private var _thrusting: Bool = false
  weak var uiDelegate: UIRocketDelegate?
  
  init() {
    let playerTexture = SKTexture(imageNamed: "player")
    let originalSize = playerTexture.size()
    let newSize = CGSize(width: originalSize.width/2, height: originalSize.height/2)
    super.init(texture: playerTexture, color: .clear, size: newSize)
    
    self.physicsBody = SKPhysicsBody(texture: playerTexture, size: self.size)
    self.physicsBody!.contactTestBitMask = self.physicsBody!.collisionBitMask
    self.physicsBody!.isDynamic = true
    self.physicsBody?.allowsRotation = false
    self.physicsBody?.restitution = 0
    self.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
    self.physicsBody?.collisionBitMask = CollisionTypes.asteroid.rawValue | CollisionTypes.edge.rawValue    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func rechargeShields() {
    let wait = SKAction.wait(forDuration: 1.2)
    let recharge = SKAction.run {
      self._shieldEnergyLevel = self._shieldEnergyLevel + 1
      self.uiDelegate?.setEnergy(to: self._shieldEnergyLevel)
    }
    let sequence = SKAction.sequence([wait, recharge])
    let loop = SKAction.repeatForever(sequence)
    self.run(loop, withKey: "rechargingShields")
  }
  
  func stopRechargingShields() {
    if action(forKey: "rechargingShields") != nil {
      self.removeAction(forKey: "rechargingShields")
    }
  }
  
  func drainShields() {
    let wait = SKAction.wait(forDuration: 1.0)
    let drain = SKAction.run {
      self._shieldEnergyLevel = self._shieldEnergyLevel - 2
      self.uiDelegate?.setEnergy(to: self._shieldEnergyLevel)
    }
    let sequence = SKAction.sequence([wait, drain])
    let loop = SKAction.repeatForever(sequence)
    self.run(loop, withKey: "drainingShields")
  }
  
  func stopDrainingShields() {
    if action(forKey: "drainingShields") != nil {
      self.removeAction(forKey: "drainingShields")
    }
  }
  
  func activateShields() {
    if _shield == nil {
      let shieldTexture = SKTexture(imageNamed: "shield")
      _shield = SKSpriteNode(texture: shieldTexture)
      _shield?.size = CGSize(width: _shield!.size.width, height: _shield!.size.height * 2)
      _shield?.zPosition = self.zPosition + 1
      _shield?.color = .blue
      _shield?.colorBlendFactor = 0.5
    }
    addChild(_shield!)
    _shield!.physicsBody = SKPhysicsBody(texture: _shield!.texture!, size: _shield!.size)
    _shield!.physicsBody?.isDynamic = false
    _shield!.physicsBody?.categoryBitMask = CollisionTypes.shield.rawValue
    _shield!.physicsBody?.collisionBitMask = CollisionTypes.asteroid.rawValue
    _shield!.physicsBody?.contactTestBitMask = CollisionTypes.asteroid.rawValue
    shieldsUp = true
    stopRechargingShields()
    drainShields()
  }
  
  func deactivateShields() {
    if _shield != nil {
      _shield?.physicsBody = nil
      _shield?.removeFromParent()
    }
    shieldsUp = false
    stopDrainingShields()
    rechargeShields()
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
