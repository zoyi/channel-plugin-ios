//
//  UIFactory.swift
//  ChannelIO
//
//  Created by intoxicated on 20/01/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import UIKit

struct UIFactory {
  static var commonParagraphStyle: NSParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.alignment = .left
    style.minimumLineHeight = 22

    return style
  }

  static var commonTextColor: UIColor {
    return UIColor.grey900
  }

  static var commonHeaderColor: UIColor {
    return UIColor.grey500
  }
}
