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
    static let inAppClipImageSide = 16.f
  }
  
  private struct Fonts {
    static let inAppName = 13.f
    static let inAppSize = 11.f
    static let inAppCount = 13.f
    static let smallName = 13.f
    static let smallSize = 12.f
    static let smallCount = 13.f
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.spacing = 4.f
  }
  
  private let clipImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "clip16")
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
    isInAppPush: Bool,
    hideFileSize: Bool = false) {
    guard let file = files.first else { return }
    
    self.fileNameLabel.text = file.name
    self.fileSizeLabel.text = "(\(file.size.toBytes))"
    self.fileCountLabel.text = "+\(files.count - 1)"
    
    self.fileNameLabel.font = isInAppPush
      ? UIFont.systemFont(ofSize: Fonts.inAppName) : UIFont.systemFont(ofSize: Fonts.smallName)
    self.fileSizeLabel.font = isInAppPush
      ? UIFont.systemFont(ofSize: Fonts.inAppSize) : UIFont.systemFont(ofSize: Fonts.smallSize)
    self.fileCountLabel.font = isInAppPush
      ? UIFont.systemFont(ofSize: Fonts.inAppCount) : UIFont.systemFont(ofSize: Fonts.smallCount)
    self.fileNameLabel.textColor = isInAppPush ? .grey700 : .grey900
    self.fileSizeLabel.textColor = isInAppPush ? .grey700 : .grey900
    self.fileCountLabel.textColor = isInAppPush ? .grey700 : .grey900
    self.clipImageView.tintColor = isInAppPush ? .grey700 : .grey900
    self.clipImageView.image = isInAppPush
      ? CHAssets.getImage(named: "clip16") : CHAssets.getImage(named: "clip12")
    self.clipImageView.snp.remakeConstraints { make in
      make.width.height.equalTo(
        isInAppPush ? Metrics.inAppClipImageSide: Metrics.smallClipImageSide
      )
    }
    
    self.fileCountLabel.isHidden = files.count <= 1
    self.fileSizeLabel.isHidden = hideFileSize
  }
}
