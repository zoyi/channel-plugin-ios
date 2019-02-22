//
//  LauncherViewModel.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 3. 2..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import UIKit

protocol LauncherViewModelType {
  var bgColor: UIColor { get }
  var badge: Int { get }
  var position: LauncherPosition { get }
  var launchIcon: UIImage? { get }
  var gradientColors: [CGColor] { get }
}

struct LauncherViewModel: LauncherViewModelType {
  var bgColor: UIColor
  var gradientColors: [CGColor]
  var badge = 0
  var position = LauncherPosition.right
  var launchIcon: UIImage?
  
  init(plugin: CHPlugin, guest: CHGuest? = nil, push: CHPush? = nil) {
    self.bgColor = UIColor(plugin.color) ?? UIColor.white
    self.badge = guest?.alert ?? 0
    self.gradientColors = [
      self.bgColor.cgColor,
      self.bgColor.cgColor,
      plugin.gradientColor?.cgColor ?? plugin.textUIColor.cgColor
    ]
    
    if let push = push, push.isNudgePush {
      self.launchIcon = CHAssets.pushIcon()
    } else if self.badge > 10 {
      self.launchIcon = CHAssets.upRightIcon()
    } else if self.badge <= 10 && self.badge != 0 {
      self.launchIcon = CHAssets.upIcon()
    } else {
      self.launchIcon = CHAssets.normalIcon()
    }
  }
}
