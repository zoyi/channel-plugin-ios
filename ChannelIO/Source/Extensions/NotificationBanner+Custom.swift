//
//  NotificationBanner+Custom.swift
//  ChannelIO
//
//  Created by Jam on 2020/04/18.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import NotificationBannerSwift

class CustomBannerColors: BannerColorsProtocol {
  internal func color(for style: BannerStyle) -> UIColor {
    switch style {
    case .warning:
      return .orange300
    default:
      return .clear
    }
  }
}

class CustomFloatingBanner {
  let banner: FloatingNotificationBanner?
  
  init(title: String, style: BannerStyle) {
    banner = FloatingNotificationBanner(
      title: title,
      titleFont: UIFont.boldSystemFont(ofSize: 13.f),
      titleTextAlign: .center,
      style: style,
      colors: CustomBannerColors()
    )
  }
  
  func show() {
    guard let banner = banner else { return }
    banner.show(
      cornerRadius: 10,
      shadowColor: .black20,
      shadowBlurRadius: 12,
      shadowEdgeInsets: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
    )
  }
}
