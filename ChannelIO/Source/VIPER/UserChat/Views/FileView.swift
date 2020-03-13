//
//  FileView.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/16.
//

import Alamofire
import NVActivityIndicatorView
import SVProgressHUD
import UIKit

final class FileView: BaseView {
  private struct Metrics {
    static let iconImageSide = 40.f
    static let iconImageLeading = 14.f
    static let iconImageTraling = 10.f
    static let fileNameTop = 16.f
    static let subLabelBottom = 15.f
    static let arrowImageLeading = 8.f
    static let arrowImageTraling = 8.f
    static let arrowImageSide = 24.f
  }
  
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
    $0.image = CHAssets.getImage(named: "chevronRight")
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
      make.width.height.equalTo(Metrics.iconImageSide)
      make.leading.equalToSuperview().inset(Metrics.iconImageLeading)
      make.centerY.equalToSuperview()
    }

    self.fileNameLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.iconImageView.snp.trailing)
        .offset(Metrics.iconImageTraling)
      make.top.equalToSuperview().inset(Metrics.fileNameTop)
      make.trailing.equalTo(self.arrowImageView.snp.leading)
        .offset(-Metrics.arrowImageLeading)
    }

    self.subLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.iconImageView.snp.trailing)
        .offset(Metrics.iconImageTraling)
      make.bottom.equalToSuperview().inset(Metrics.subLabelBottom)
      make.trailing.equalTo(self.arrowImageView.snp.leading)
        .offset(-Metrics.arrowImageLeading)
    }

    self.arrowImageView.snp.makeConstraints { make in
      make.width.height.equalTo(Metrics.arrowImageSide)
      make.trailing.equalToSuperview().inset(Metrics.arrowImageTraling)
      make.centerY.equalToSuperview()
    }
  }

  func configure(with file: CHFile) {
    self.fileNameLabel.text = file.name
    let ext = file.ext.lowercased()
    self.subLabel.text = file.size.toBytes + (ext != "" ? " • " + ext : "")
    if let type = CHUtils.fileTypesMap()[ext] {
      self.iconImageView.image = CHAssets.getImage(named: type)
    } else {
      self.iconImageView.image = CHAssets.getImage(named: "file")
    }
  }
}
