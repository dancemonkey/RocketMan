//
//  ScoreDisplay.swift
//  RocketMan
//
//  Created by Drew Lanning on 10/10/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit
import SpriteKit

class ScoreDisplay: SKSpriteNode {

  private var _score: Int = 0 {
    didSet {
      _scoreLabel.text = "Score: \(score)"
    }
  }
  var score: Int {
    get {
      return _score
    }
  }
  
  private var _highScore: Int? {
    didSet {
      _highScoreLabel.text = "High Score: \(highScore)"
    }
  }
  var highScore: Int {
    get {
      return _highScore ?? 0
    }
  }
  
  private var _scoreLabel: SKLabelNode!
  private var _highScoreLabel: SKLabelNode!
  
  init() {
    super.init(texture: nil, color: .clear, size: CGSize(width: 20, height: 100))
    _highScore = UserDefaults().integer(forKey: UserDefaultKeys.highScore.rawValue)
    _scoreLabel = SKLabelNode(text: "Score: \(self.score)")
    _highScoreLabel = SKLabelNode(text: "High Score: \(self.highScore)")
    _highScoreLabel.position = CGPoint(x: _scoreLabel.position.x, y: _scoreLabel.position.y - 40)
    self.addChild(_scoreLabel)
    self.addChild(_highScoreLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addToScore(score: Int) {
    self._score = self._score + score
  }
  
  func setNewHighScore() {
    if let highScore = _highScore, highScore < self.score {
      self._highScore = score
      let defaults = UserDefaults()
      defaults.set(score, forKey: UserDefaultKeys.highScore.rawValue)
    }
    
  }
  
}
