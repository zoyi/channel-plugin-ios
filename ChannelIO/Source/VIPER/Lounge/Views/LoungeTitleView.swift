//
//  LoungetTtleView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 30/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

class LoungeTitleView: BaseView {
  let channelNameLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 22)
    $0.textAlignment = .left
  }
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.channelNameLabel)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.channelNameLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
  
  func configure(channel: CHChannel, plugin: CHPlugin) {
    self.channelNameLabel.text = channel.name
    self.channelNameLabel.textColor = plugin.textUIColor
  }
  
  override var intrinsicContentSize: CGSize {
    return UIView.layoutFittingExpandedSize
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    return CGSize(width: UIScreen.main.bounds.width, height: 35)
  }
}
