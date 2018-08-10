//
//  GameScene.swift
//  RocketMan
//
//  Created by Drew Lanning on 8/10/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  var player: SKSpriteNode!
  var exhaustPlume: SKEmitterNode?

  override func didMove(to view: SKView) {
    createPlayer()
  }
  
  func createPlayer() {
    print("creating player")
    let playerTexture = SKTexture(imageNamed: "player")
    player = SKSpriteNode(texture: playerTexture)
    player.zPosition = 10
    player.position = CGPoint(x: frame.midX, y: frame.midY)
    addChild(player)
    
//    player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size())
//    player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
//    player.physicsBody?.isDynamic = false
//    player.physicsBody?.collisionBitMask = 0
  }
  
  func createPlume() {
    if let plume = SKEmitterNode(fileNamed: "exhaust") {
      exhaustPlume = plume
      exhaustPlume!.position = player.position
      exhaustPlume!.position.y = plume.position.y - (player.size.height/2)
      addChild(exhaustPlume!)
    }
  }
  
  func removePlume() {
    if exhaustPlume != nil {
      exhaustPlume?.removeFromParent()
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    createPlume()
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    removePlume()
  }
  
}
