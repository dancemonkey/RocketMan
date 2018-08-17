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
  
  init() {
    let rand = GKRandomDistribution(forDieWithSideCount: 10)
    let rockTexture = SKTexture(imageNamed: "meteor\(rand.nextInt())")
    let newSize = CGSize(width: rockTexture.size().width*2, height: rockTexture.size().height*2)
    super.init(texture: rockTexture, color: .clear, size: newSize)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
