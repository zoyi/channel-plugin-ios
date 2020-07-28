//
//  CHBooleanSelectCell.swift
//  ChannelIO
//
//  Created by 김진학 on 2020/07/22.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import SnapKit

final class CHBooleanSelectCell: BaseTableViewCell {
  private enum Metrics {
    static var fontSize = 17.f
    static var labelPadding = 16.f
    static var iconPadding = 15.f
    static var iconSize = 24.f
  }

  private let label = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: Metrics.fontSize)
    $0.textColor = .grey900
  }

  private let selectedIcon = UIImageView().then {
    $0.image = CHAssets.getImage(named: "check")
    $0.isHidden = true
  }

  override func initialize() {
    super.initialize()

    self.contentView.addSubview(self.label)
    self.contentView.addSubview(self.selectedIcon)
  }

  override func setLayouts() {
    super.setLayouts()

    self.label.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(Metrics.labelPadding)
      make.trailing.equalTo(self.selectedIcon.snp.leading).offset(Metrics.labelPadding)
    }

    self.selectedIcon.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(Metrics.iconPadding)
      make.width.height.equalTo(Metrics.iconSize)
    }
  }

  func configure(text: String, isSelect: Bool) {
    self.label.text = text
    self.selectedIcon.isHidden = !isSelect
  }
}
