//
//  UIDelegate.swift
//  RocketMan
//
//  Created by Drew Lanning on 8/12/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import Foundation

protocol UIRocketDelegate: class {
  func setEnergy(to amount: Double)
  func destroyRocket()
}
