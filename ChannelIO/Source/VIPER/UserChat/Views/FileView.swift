//
//  FileView.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/16.
//

import Alamofire
import M13ProgressSuite
import NVActivityIndicatorView
import SVProgressHUD
import UIKit

final class FileView: BaseView {
  let iconImageView = UIImageView().then {
    $0.contentMode = .center
  }

  let fileNameLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 15)
    $0.textColor = UIColor.grey900
    $0.numberOfLines = 1
  }

  let subLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = UIColor.grey500
    $0.numberOfLines = 1
  }

  let arrowImageView = UIImageView().then {
    $0.contentMode = .center
    $0.image = CHAssets.getImage(named: "chevronRightSmall")
  }

  static let HEIGHT: CGFloat = 70.0

  var file: CHFile! {
    didSet {
      self.fileNameLabel.text = self.file.name
      let ext = self.file.ext
      self.subLabel.text = self.file.size.toBytes + " • " + ext
      // TODO: change image to ext
      self.iconImageView.image = CHAssets.getImage(named: "else")
    }
  }

  override func initialize() {
    super.initialize()

    self.layer.borderColor = UIColor.dark20.cgColor
    self.layer.borderWidth = 1
    self.layer.cornerRadius = 6

    self.addSubview(self.iconImageView)
    self.addSubview(self.fileNameLabel)
    self.addSubview(self.subLabel)
    self.addSubview(self.arrowImageView)
  }

  override func setLayouts() {
    super.setLayouts()

    self.iconImageView.snp.makeConstraints { make in
      make.size.equalTo(CGSize(width: 33, height: 42))
      make.leading.equalToSuperview().inset(14)
      make.centerY.equalToSuperview()
    }

    self.fileNameLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.iconImageView.snp.trailing).offset(12)
      make.height.equalTo(22)
      make.top.equalToSuperview().inset(14)
      make.trailing.equalTo(self.arrowImageView.snp.leading).offset(-4)
    }

    self.subLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.iconImageView.snp.trailing).offset(12)
      make.height.equalTo(22)
      make.bottom.equalToSuperview().inset(11)
      make.trailing.equalTo(self.arrowImageView.snp.leading).offset(-4)
    }

    self.arrowImageView.snp.makeConstraints { make in
      make.size.equalTo(CGSize(width: 24, height: 24))
      make.trailing.equalToSuperview().inset(6)
      make.centerY.equalToSuperview()
    }
  }

  func configure(with model: CHFile) {
  }
}
