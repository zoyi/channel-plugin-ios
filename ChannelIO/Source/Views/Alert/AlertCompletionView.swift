//
//  AlertCompletionView.swift
//  ChannelIO
//
//  Created by Jam on 2020/03/05.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Foundation

class AlertCompletionView: BaseView {
  let completionImageView = UIImageView()
  let titleLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 14)
    $0.textColor = UIColor.grey900
  }

  override func initialize() {
    super.initialize()
    self.backgroundColor = .white

    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOffset = CGSize(width: 0.f, height: 4.f)
    self.layer.shadowRadius = 4.f
    self.layer.shadowOpacity = 0.3
    self.layer.borderWidth = 1.f
    self.layer.borderColor = UIColor.grey300.cgColor
    self.layer.cornerRadius = 6.f

    self.addSubview(self.completionImageView)
    self.addSubview(self.titleLabel)
  }

  override func setLayouts() {
    super.setLayouts()

    self.completionImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(13)
      make.centerX.equalToSuperview()
      make.height.equalTo(36)
      make.width.equalTo(36)
    }

    self.titleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.completionImageView.snp.bottom).offset(10)
      make.leading.equalToSuperview().inset(25)
      make.trailing.equalToSuperview().inset(25)
      make.bottom.equalToSuperview().inset(18)
      make.centerX.equalToSuperview()
    }
  }

  func configure(title: String, imageName: String) {
    self.completionImageView.image = UIImage(named: imageName)
    self.titleLabel.text = title
  }
}

