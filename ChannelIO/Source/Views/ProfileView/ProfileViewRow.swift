//
//  ProfileViewRow.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 13..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import ManualLayout

class ProfileViewRow: BaseView {

  // MARK: - Constants

  struct Fonts {
    static let titleLabel = UIFont.boldSystemFont(ofSize: 14)
    static let contentLabel = UIFont.boldSystemFont(ofSize: 14)
  }

  struct Colors {
    static let titleLabel = CHColors.gray
    static let contentLabel = CHColors.dark
  }

  struct Metric {
    static let paddingLeft = 17.f
    static let paddingRight = 17.f
    static let titlePaddingRight = 10.f
  }

  // MARK: - Properties

  let titleLabel = UILabel().then {
    $0.font = Fonts.titleLabel
    $0.textColor = Colors.titleLabel
  }

  let contentLabel = UILabel().then {
    $0.font = Fonts.contentLabel
    $0.textColor = Colors.contentLabel
  }

  // MARK: - Initializing

  override func initialize() {
    super.initialize()
    self.backgroundColor = CHColors.white
    self.addSubview(self.titleLabel)
    self.addSubview(self.contentLabel)
  }
  
  // MARK: - Configuring

  func configure(_ viewModel: (String, String?)) {
    self.titleLabel.text = viewModel.0
    self.contentLabel.text = viewModel.1
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.titleLabel.top = 0
    self.titleLabel.left = Metric.paddingLeft
    self.titleLabel.sizeToFit()
    self.titleLabel.height = self.height

    self.contentLabel.top = 0
    self.contentLabel.left = Metric.paddingLeft + self.titleLabel.width + Metric.titlePaddingRight
    self.contentLabel.width = self.width - self.contentLabel.left - Metric.paddingRight
    self.contentLabel.height = self.height
  }
}
