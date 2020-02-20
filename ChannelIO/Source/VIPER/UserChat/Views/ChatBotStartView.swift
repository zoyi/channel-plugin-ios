//
//  ChatBotStartView.swift
//  ChannelIO
//
//  Created by Jam on 2020/02/17.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Foundation

class ChatBotStartView: BaseView {
  struct Metrics {
    static let viewHeight = 45.f
    static let labelLeading = 8.f
  }
  
  let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.borderWidth = 2.f
    $0.layer.borderColor = UIColor.whiteBorder.cgColor
    $0.layer.cornerRadius = 4.f
    $0.dropShadow(
      with: CHColors.black10,
      opacity: 0.5,
      offset: CGSize(width: 0, height: 2),
      radius: 2
    )
  }
  
  let centerView = UIView()
  
  let imageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "bot")
  }
  
  let messageLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 15)
    $0.textColor = .cobalt400
    $0.text = CHAssets.localized("ch.chat.marketing_to_support_bot")
  }
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.containerView)
    self.containerView.addSubview(self.centerView)
    self.centerView.addSubview(self.messageLabel)
    self.centerView.addSubview(self.imageView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.containerView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.centerView.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
    }
    
    self.imageView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview()
      make.centerY.equalToSuperview()
    }
    
    self.messageLabel.snp.makeConstraints { (make) in
      make.leading.equalTo(self.imageView.snp.trailing).offset(Metrics.labelLeading)
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview()
    }
  }
  
  func viewHeight() -> CGFloat {
    return Metrics.viewHeight
  }
}
