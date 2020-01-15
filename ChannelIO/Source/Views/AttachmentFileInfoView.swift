//
//  AttachmentFileInfoView.swift
//  ChannelIO
//
//  Created by Jam on 2020/01/08.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import SnapKit

class AttachmentFileInfoView: BaseView {
  private struct Metrics {
    static let containerHeight = 18.f
    static let smallClipImageSide = 12.f
    static let largeClipImageSide = 16.f
  }
  
  private struct Fonts {
    static let largeName = 14.f
    static let largeSize = 12.f
    static let largeCount = 14.f
    static let smallName = 13.f
    static let smallSize = 12.f
    static let smallCount = 13.f
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.spacing = 2.f
  }
  
  private let clipImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "clipSmall900")
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 4.f
  }
  
  private let fileNameLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: Fonts.smallName)
    $0.textColor = .grey900
  }
  
  private let fileSizeLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: Fonts.smallSize)
    $0.textColor = .grey500
  }
  
  private let fileCountLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: Fonts.smallCount)
    $0.textColor = .grey900
  }
  
  override func initialize() {
    super.initialize()
    
    self.contentStackView.addArrangedSubview(self.fileNameLabel)
    self.contentStackView.addArrangedSubview(self.fileSizeLabel)
    self.contentStackView.addArrangedSubview(self.fileCountLabel)
    self.containerView.addArrangedSubview(self.clipImageView)
    self.containerView.addArrangedSubview(self.contentStackView)
    self.addSubview(self.containerView)
    
    self.fileNameLabel.setContentCompressionResistancePriority(
      .defaultLow, for: .horizontal
    )
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.containerView.snp.makeConstraints { make in
      make.top.bottom.leading.equalToSuperview()
      make.height.equalTo(Metrics.containerHeight)
      make.trailing.lessThanOrEqualToSuperview()
    }
    
    self.clipImageView.snp.makeConstraints { make in
      make.width.equalTo(Metrics.smallClipImageSide)
      make.height.equalTo(Metrics.smallClipImageSide)
    }
  }
  
  func configure(
    with files: [CHFile],
    isLarge: Bool,
    hideFileSize: Bool = false) {
    guard let file = files.first else { return }
    
    self.fileNameLabel.text = file.name
    self.fileSizeLabel.text = "(\(file.size.toBytes))"
    self.fileCountLabel.text = "+\(files.count - 1)"
    
    if isLarge {
      self.fileNameLabel.font = UIFont.systemFont(ofSize: Fonts.largeName)
      self.fileSizeLabel.font = UIFont.systemFont(ofSize: Fonts.largeSize)
      self.fileCountLabel.font = UIFont.systemFont(ofSize: Fonts.largeCount)
      self.clipImageView.image = CHAssets.getImage(named: "clipLarge900")
      self.clipImageView.snp.remakeConstraints { make in
        make.width.equalTo(Metrics.largeClipImageSide)
        make.height.equalTo(Metrics.largeClipImageSide)
      }
    } else {
      self.fileNameLabel.font = UIFont.systemFont(ofSize: Fonts.smallName)
      self.fileSizeLabel.font = UIFont.systemFont(ofSize: Fonts.smallSize)
      self.fileCountLabel.font = UIFont.systemFont(ofSize: Fonts.smallCount)
      self.clipImageView.image = CHAssets.getImage(named: "clipSmall900")
      self.clipImageView.snp.remakeConstraints { make in
        make.width.equalTo(Metrics.smallClipImageSide)
        make.height.equalTo(Metrics.smallClipImageSide)
      }
    }
    
    self.fileCountLabel.isHidden = files.count <= 1
    self.fileSizeLabel.isHidden = hideFileSize
  }
}
