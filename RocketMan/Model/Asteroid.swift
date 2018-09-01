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
  var massFactor: CGFloat?
  
  init() {
    let rand = GKRandomDistribution(forDieWithSideCount: 10)
    let rockTexture = SKTexture(imageNamed: "\(ImageName.meteor.rawValue)\(rand.nextInt())")
    let newSize = CGSize(width: rockTexture.size().width*2, height: rockTexture.size().height*2)
    super.init(texture: rockTexture, color: .clear, size: newSize)
    
    self.name = "asteroid"
    self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2)
    self.physicsBody!.contactTestBitMask = self.physicsBody!.collisionBitMask
    self.physicsBody!.isDynamic = true
    self.physicsBody?.allowsRotation = true
    self.physicsBody?.restitution = 0
    self.physicsBody?.categoryBitMask = CollisionTypes.asteroid.rawValue
    self.physicsBody?.collisionBitMask = CollisionTypes.player.rawValue | CollisionTypes.asteroid.rawValue
    self.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
    massFactor = self.physicsBody!.mass * 10
    randomRotation()
  }
  
  func randomVector(fromLeftSide leftSide: Bool) -> CGVector {
    var xRand = GKRandomDistribution(lowestValue: 10, highestValue: 30).nextInt()
    let yRand = GKRandomDistribution(lowestValue: -100, highestValue: -80).nextInt()
    
    if leftSide == false {
      xRand = xRand * -1
    }
    
    return CGVector(dx: CGFloat(xRand) * massFactor!, dy: CGFloat(yRand) * massFactor!)
  }
  
  func randomRotation() {
    let duration = GKRandomDistribution.d6()
    let direction = GKRandomDistribution().nextBool()
    let directionChange: CGFloat = direction == true ? 1 : -1
    let rotate = SKAction.rotate(byAngle: (.pi * 2) * directionChange , duration: Double(duration.nextInt()))
    let repeatRotate = SKAction.repeatForever(rotate)
    self.run(repeatRotate)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
