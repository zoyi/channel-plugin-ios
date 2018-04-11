//
//  LaunchViewModel.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 3. 2..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import UIKit

protocol LaunchViewModelType {
  var xMargin: CGFloat { get }
  var yMargin: CGFloat { get }
  var bgColor: String { get }
  var borderColor: String { get }
  var badge: Int { get }
  var iconColor: UIColor { get }
}

struct LaunchViewModel: LaunchViewModelType {
  var xMargin = 24.f
  var yMargin = 24.f
  var bgColor = "#00A6FF"
  var borderColor = ""
  var badge = 0
  var iconColor = UIColor.white

  init(plugin: CHPlugin, guest: CHGuest? = nil) {
    self.xMargin = CGFloat(plugin.mobileMarginX)
    self.yMargin = CGFloat(plugin.mobileMarginY)
    self.bgColor = plugin.color
    self.borderColor = plugin.borderColor
    self.iconColor = (plugin.textColor == "white") ? UIColor.white : UIColor.black
    self.badge = guest?.alert ?? 0
  }
}
