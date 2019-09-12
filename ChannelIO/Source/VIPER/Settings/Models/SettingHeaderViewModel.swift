//
//  SettingHeaderViewModel.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

struct SettingHeaderViewModel {
  var title: String
  var homepageUrl: String?
  var desc: String?
  var entity: CHEntity
  var colors: [UIColor]
  var textColor: UIColor
  
  init(channel: CHChannel, plugin: CHPlugin) {
    self.title = channel.name
    self.homepageUrl = channel.homepageUrl
    self.desc = channel.desc
    self.entity = channel
    self.colors = plugin.gradientColors
    self.textColor = plugin.textUIColor
  }
}
