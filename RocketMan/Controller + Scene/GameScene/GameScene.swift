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

enum ImageName: String {
  case player
  case shield
  case meteor
}

enum Keys: String {
  case thrusting
  case rechargingShields
  case drainingShields
  case lowEnergyFlashing
}

enum UserDefaultKeys: String {
  case highScore
}

enum GameState {
  case logo
  case playing
  case gameOver
}

class GameScene: SKScene, UIRocketDelegate, SKPhysicsContactDelegate {
  
  var player: RocketNode!
  var shieldEnergyDisplay: EnergyDisplay!
  var scoreDisplay: ScoreDisplay!
  var scoring = false
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
  private var asteroidDelay: Int = 4
  private var logo: SKLabelNode!
  private var gameOver: SKLabelNode!
  var hint: SKLabelNode!
  private var gameState: GameState = .logo
  let generator = UINotificationFeedbackGenerator()
  
  override func didMove(to view: SKView) {
    
  }
  
  override func sceneDidLoad() {
    super.sceneDidLoad()
    createBackground()
    createPlayer()
    createEnergyDisplay()
    createBoundaries()
    createLabels()
    setupScore()
    motionManager = CMMotionManager()
    generator.prepare()
    
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    view?.ignoresSiblingOrder = true
  }
  
  override func update(_ currentTime: TimeInterval) {
    super.update(currentTime)
    
    for (index, asteroid) in asteroids.enumerated() {
      asteroid.lifetime = asteroid.lifetime + 1
      if asteroidOutOfBounds(asteroid) && asteroid.position.y < -50 {
        if scoring {
          scoreDisplay.addToScore(score: Int(asteroid.massFactor!))
        }
        asteroid.physicsBody = nil
        asteroid.removeAllActions()
        asteroid.removeFromParent()
        asteroids.remove(at: index)
      }
    }
    
    #if targetEnvironment(simulator)
    #else
    if let accelerometerData = motionManager.accelerometerData {
      self.player.physicsBody?.applyImpulse(CGVector(dx: accelerometerData.acceleration.x * 10, dy: 0.0))
    }
    #endif
  }
  
  func setupScore() {
    scoreDisplay = ScoreDisplay()
    scoreDisplay.zPosition = 0
    scoreDisplay.position = CGPoint(x: self.frame.width - 125, y: self.frame.height - 40)
    addChild(scoreDisplay)
    scoring = true
  }
  
  func createEnergyDisplay() {
    shieldEnergyDisplay = EnergyDisplay(withColor: .blue)
    shieldEnergyDisplay.zPosition = 0
    shieldEnergyDisplay.position = CGPoint(x: 5, y: 5)
    addChild(shieldEnergyDisplay)
  }
  
  func startAsteroidBelt() {
    let xRand = GKRandomDistribution(lowestValue: 20, highestValue: Int(self.frame.width - 20))
    let randomCreate = GKRandomDistribution(forDieWithSideCount: asteroidDelay)
    let create = SKAction.run { [unowned self] in
      self.createAsteroid(at: CGPoint(x: xRand.nextInt(), y: Int(self.frame.height + 100)))
    }
    let wait = SKAction.wait(forDuration: Double(randomCreate.nextInt()))
    let sequence = SKAction.sequence([create, wait])
    let repeatForever = SKAction.repeatForever(sequence)
    run(repeatForever)
  }
  
  func createAsteroid(at point: CGPoint) {
    let asteroid = Asteroid()
    let leftSide: Bool = (point.x < (self.frame.midX)) ? true : false
    asteroid.position = point
    asteroid.zPosition = -10
    addChild(asteroid)
    asteroids.append(asteroid)
    
    if playerHuggingEdge() {
      asteroid.position.x = player.position.x
      asteroid.physicsBody?.applyImpulse(asteroid.straightLineVector())
    } else {
      asteroid.physicsBody?.applyImpulse(asteroid.randomVector(fromLeftSide: leftSide))
    }
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
    switch gameState {
    case .logo:
      gameState = .playing
      let fadeOut = SKAction.fadeOut(withDuration: 0.5)
      let remove = SKAction.removeFromParent()
      let wait = SKAction.wait(forDuration: 0.5)
      let startGame = SKAction.run { [ unowned self ] in
        self.startAsteroidBelt()
        self.player.createPlume()
        self.thrusting = true
        self.motionManager.startAccelerometerUpdates()
      }
      
      let logoSequence = SKAction.sequence([fadeOut, wait, startGame, remove])
      logo.run(logoSequence)
      let newHint = SKAction.run {
        self.hint.text = "Tap & hold for shields"
      }
      let hintWait = SKAction.wait(forDuration: 3)
      let hintSequence = SKAction.sequence([newHint, hintWait, fadeOut, remove])
      hint.run(hintSequence)
      
    case .playing:
      player.activateShields()
    case .gameOver:
      let scene = GameScene(fileNamed: "GameScene")!
      scene.scaleMode = .aspectFit
      let transition = SKTransition.flipVertical(withDuration: 1)
      self.view?.presentScene(scene, transition: transition)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    player.deactivateShields()
  }
  
  func playerHuggingEdge() -> Bool {
    if player.position.x < player.size.width || player.position.x > (self.size.width - player.size.width) {
      return true
    }
    return false
  }
  
  func destroyRocket() {
    if let explosion = SKEmitterNode(fileNamed: "explosion") {
      scoring = false
      explosion.position = player.position
      player.removePlume()
      player.removeAllActions()
      setEnergy(to: 0)
      addChild(explosion)
      scoreDisplay.setNewHighScore()
      generator.notificationOccurred(.error)
      let explosionSound = SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false)
      self.run(explosionSound)
      player.removeFromParent()
      shieldEnergyDisplay.removeShieldAlertSound()
      self.thrusting = false
      gameOver.alpha = 1
      hint.text = "Tap to restart"
      hint.alpha = 1.0
      if hint.inParentHierarchy(self) {
        hint.removeFromParent()
      }
      addChild(hint)
      gameState = .gameOver
    }
  }
  
  func createLabels() {
    logo = SKLabelNode(text: "ROCKET")
    logo.fontSize = 75.0
    logo.position = CGPoint(x: frame.midX, y: frame.midY)
    addChild(logo)
    
    gameOver = SKLabelNode(text: "GAME OVER")
    gameOver.fontSize = 75.0
    gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
    gameOver.alpha = 0
    addChild(gameOver)
    
    hint = SKLabelNode(text: "Tap to start")
    hint.fontSize = 40.0
    hint.position = CGPoint(x: frame.midX, y: (player.position.y - player.size.height))
    addChild(hint)
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    if contact.bodyA.node == player || contact.bodyB.node == player {
      if contact.bodyA.node?.name == "border" || contact.bodyB.node?.name == "border" {
        return
      }
      if contact.bodyA.node == player {
        player.impact(by: contact.bodyB.node! as! Asteroid, at: contact.contactPoint)
      } else {
        player.impact(by: contact.bodyA.node! as! Asteroid, at: contact.contactPoint)
      }
    } else {
      return
    }
  }
}
