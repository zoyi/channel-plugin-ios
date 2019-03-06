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
    let gradientColor = UIColor(plugin.gradientColor) ?? UIColor.white
    
    self.badge = guest?.alert ?? 0
    self.gradientColors = [
      self.bgColor.cgColor,
      self.bgColor.cgColor,
      gradientColor.cgColor
    ]
    
    if self.badge == 0 {
      self.launchIcon = plugin.textColor == "white" ?
        CHAssets.normalIcon() : CHAssets.normalBlackIcon()
    } else if let push = push, push.isNudgePush {
      self.launchIcon = plugin.textColor == "white" ?
        CHAssets.pushIcon() : CHAssets.pushBlackIcon()
    } else if self.badge >= 10 {
      self.launchIcon = plugin.textColor == "white" ?
        CHAssets.upRightIcon() : CHAssets.upRightBlackIcon()
    } else {
      self.launchIcon = plugin.textColor == "white" ?
        CHAssets.upIcon() : CHAssets.upBlackIcon()
    }
  }
}
