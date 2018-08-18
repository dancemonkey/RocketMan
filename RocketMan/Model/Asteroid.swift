//
//  Asteroid.swift
//  RocketMan
//
//  Created by Drew Lanning on 8/17/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class Asteroid: SKSpriteNode {

  var lifetime: Double = 0
  var minLifetime: Double = 360
  
  init() {
    let rand = GKRandomDistribution(forDieWithSideCount: 10)
    let rockTexture = SKTexture(imageNamed: "meteor\(rand.nextInt())")
    let newSize = CGSize(width: rockTexture.size().width*2, height: rockTexture.size().height*2)
    super.init(texture: rockTexture, color: .clear, size: newSize)
    
    self.name = "asteroid"
    self.physicsBody = SKPhysicsBody(texture: rockTexture, size: self.size)
    self.physicsBody!.contactTestBitMask = self.physicsBody!.collisionBitMask
    self.physicsBody!.isDynamic = true
    self.physicsBody?.allowsRotation = true
    self.physicsBody?.restitution = 0
    self.physicsBody?.categoryBitMask = CollisionTypes.asteroid.rawValue
    self.physicsBody?.collisionBitMask = CollisionTypes.player.rawValue | CollisionTypes.asteroid.rawValue
  }
  
  func randomVector() -> CGVector {
    print("size: \(self.size), mass: \(self.physicsBody!.mass)")
    let xRand = GKRandomDistribution(lowestValue: -20, highestValue: 20)
    let yRand = GKRandomDistribution(lowestValue: -100, highestValue: -80)
    if physicsBody!.mass > 0.8 {
      return CGVector(dx: xRand.nextInt() * 6, dy: yRand.nextInt() * 6)
    } else if physicsBody!.mass < 0.1 {
      return CGVector(dx: CGFloat(xRand.nextInt()) * 0.75, dy: CGFloat(yRand.nextInt()) * 0.75)
    } else {
      return CGVector(dx: xRand.nextInt(), dy: yRand.nextInt())
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
