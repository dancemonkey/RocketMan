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
  private var _shieldAudio: SKAudioNode?
  private var _impactSound: SKAudioNode?
  private var _shieldEnergyLevel: Double = 100 {
    didSet {
      if _shieldEnergyLevel >= 100 {
        stopRechargingShields()
        _shieldEnergyLevel = 100
      } else if _shieldEnergyLevel <= 0 {
        _shieldEnergyLevel = 0
        deactivateShields()
      }
    }
  }
  var shieldEnergyLevel: Double {
    return _shieldEnergyLevel
  }
  private var _velocity: Double?
  private var _thrusting: Bool = false
  weak var uiDelegate: UIRocketDelegate?
  private var rechargeRate: Double = 1
  private var drainRate: Double = 9
  private let generator = UIImpactFeedbackGenerator(style: .heavy)
  
  init() {
    let playerTexture = SKTexture(imageNamed: ImageName.player.rawValue)
    let originalSize = playerTexture.size()
    let newSize = CGSize(width: originalSize.width/2, height: originalSize.height/2)
    super.init(texture: playerTexture, color: .clear, size: newSize)
    generator.prepare()
    
    initializePhysicsBody()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func initializePhysicsBody() {
    self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
    self.physicsBody!.contactTestBitMask = self.physicsBody!.collisionBitMask
    self.physicsBody!.isDynamic = true
    self.physicsBody!.allowsRotation = false
    self.physicsBody!.restitution = 0
    self.physicsBody!.categoryBitMask = CollisionTypes.player.rawValue
    self.physicsBody!.collisionBitMask = CollisionTypes.asteroid.rawValue | CollisionTypes.edge.rawValue
  }
  
  func damageShields(by amount: Double) {
    _shieldEnergyLevel = _shieldEnergyLevel - amount
    uiDelegate?.setEnergy(to: self._shieldEnergyLevel)
  }
  
  func rechargeShields() {
    let wait = SKAction.wait(forDuration: 1.2)
    let recharge = SKAction.run {
      self._shieldEnergyLevel = self._shieldEnergyLevel + self.rechargeRate
      self.uiDelegate?.setEnergy(to: self._shieldEnergyLevel)
    }
    let sequence = SKAction.sequence([wait, recharge])
    let loop = SKAction.repeatForever(sequence)
    self.run(loop, withKey: Keys.rechargingShields.rawValue)
  }
  
  func stopRechargingShields() {
    if action(forKey: Keys.rechargingShields.rawValue) != nil {
      self.removeAction(forKey: Keys.rechargingShields.rawValue)
    }
  }
  
  func drainShields() {
    let wait = SKAction.wait(forDuration: 1.0)
    let drain = SKAction.run {
      self._shieldEnergyLevel = self._shieldEnergyLevel - self.drainRate
      self.uiDelegate?.setEnergy(to: self._shieldEnergyLevel)
    }
    let sequence = SKAction.sequence([wait, drain])
    let loop = SKAction.repeatForever(sequence)
    self.run(loop, withKey: Keys.drainingShields.rawValue)
  }
  
  func stopDrainingShields() {
    if action(forKey: Keys.drainingShields.rawValue) != nil {
      self.removeAction(forKey: Keys.drainingShields.rawValue)
    }
  }
  
  func activateShields() {
    if _shield == nil {
      let shieldTexture = SKTexture(imageNamed: ImageName.shield.rawValue)
      _shield = SKSpriteNode(texture: shieldTexture)
      _shield?.size = CGSize(width: _shield!.size.width, height: _shield!.size.height * 2)
      _shield?.zPosition = self.zPosition + 1
      _shield?.color = .blue
      _shield?.colorBlendFactor = 0.5
    }
    addChild(_shield!)
    
    if let shieldSound = _shieldAudio {
      addChild(shieldSound)
    } else if let shieldSoundURL = Bundle.main.url(forResource: "shield", withExtension: "mp3") {
      _shieldAudio = SKAudioNode(url: shieldSoundURL)
      addChild(_shieldAudio!)
    }
    _shieldAudio?.run(SKAction.changeVolume(to: 3.0, duration: 0))
    
    shieldsUp = true
    stopRechargingShields()
    drainShields()
  }
  
  func deactivateShields() {
    _shield?.removeFromParent()
    _shieldAudio?.removeFromParent()
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
    if let thrustSound = _thrusterAudio {
      addChild(thrustSound)
    } else if let audio = Bundle.main.url(forResource: "engineLoop", withExtension: "wav") {
      _thrusterAudio = SKAudioNode(url: audio)
      addChild(_thrusterAudio!)
    }
    _thrusterAudio?.run((SKAction.changeVolume(to: 0.5, duration: 0)))
  }
  
  func removePlume() {
    self._thrusting = false
    if _exhaustPlume != nil {
      _exhaustPlume?.removeFromParent()
    }
    _thrusterAudio?.removeFromParent()
  }
  
  func playImpactSound() {
    let playSound = SKAction.playSoundFileNamed("shieldHit.mp3", waitForCompletion: false)
    self.run(playSound)
  }
  
  func impact(by asteroid: Asteroid, at contactPoint: CGPoint) {
    if shieldsUp {
      generator.impactOccurred()
      let damage = Double(asteroid.massFactor!) * 1.5
      if damage > _shieldEnergyLevel {
        uiDelegate?.destroyRocket()
      } else {
        damageShields(by: damage)
        let impactFX = SKEmitterNode(fileNamed: "shieldImpact")
        impactFX?.position = self.scene!.convert(contactPoint, to: self)
        let addImpact = SKAction.run {
          self.addChild(impactFX!)
          self.playImpactSound()
        }
        let wait = SKAction.wait(forDuration: 1.5)
        let removeImpact = SKAction.run {
          impactFX?.removeFromParent()
        }
        let sequence = SKAction.sequence([addImpact, wait, removeImpact])
        self.run(sequence)
      }
    } else {
      uiDelegate?.destroyRocket()
    }
  }
  
}
