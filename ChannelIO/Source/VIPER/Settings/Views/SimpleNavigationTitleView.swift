//
//  SimpleNavigationTitleView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 07/05/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import UIKit
import SnapKit

class SimpleNavigationTitleView: BaseView {
  struct Metric {
    static let titleHeight = 22.f
    static let imageSize = 22.f
  }
  
  let titleLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 17)
  }
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.titleLabel)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.titleLabel.snp.makeConstraints { (make) in
      make.height.equalTo(Metric.titleHeight)
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
  }
  
  func configure(with title: String, textColor: UIColor) {
    self.titleLabel.text = title
    self.titleLabel.textColor = textColor
  }
  
  func configure(with i18nTitle: CHi18n?, textColor: UIColor) {
    guard let title = i18nTitle else { return }

    self.titleLabel.attributedText = title.getAttributedMessage(
      with: CHMessageParserConfig(
        font: UIFont.systemFont(ofSize: 17),
        textColor: textColor
      ))
  }
  
  override var intrinsicContentSize: CGSize {
    let width = UIScreen.main.bounds.width - 120
    return CGSize(width: width, height: 44)
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let width = UIScreen.main.bounds.width - 120
    return CGSize(width: width, height: 44)
  }
}
