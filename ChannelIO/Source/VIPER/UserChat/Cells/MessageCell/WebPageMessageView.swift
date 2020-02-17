//
//  WebpageView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 16/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import SDWebImage
import SnapKit

final class WebPageMessageView: BaseView {
  private struct Metrics {
    static let sectionBarWidth = 4.f
    static let componentInSectionTop = 2.f
    static let componentInSectionBottom = 2.f
    static let imageViewBottom = 10.f
    static let sectionBarTrailing = 10.f
    static let descTop = 5.f
    static let providerTop = 8.f
    static let providerHeight = 16.f
    static let imageHeight = 157.f
    static let titleMaxLines = 1
    static let descMaxLines = 2
    static let webPageMessageViewBottom = 10.f
  }
  
  private struct Fonts {
    static let title = UIFont.boldSystemFont(ofSize: 14)
    static let desc = UIFont.systemFont(ofSize: 12)
  }

  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.layer.borderColor = UIColor.grey300.cgColor
    $0.layer.borderWidth = 1
    $0.layer.cornerRadius = 6
  }

  private let videoView = VideoPlayerView().then {
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 6.f
    $0.layer.borderColor = UIColor.grey300.cgColor
    $0.layer.borderWidth = 1
    $0.isHidden = true
  }

  private let sectionBar = UIView().then {
    $0.backgroundColor = UIColor.grey300
    $0.layer.cornerRadius = 1.f
  }
  
  private let infoStackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .leading
    $0.spacing = 2.f
  }

  private let titleLabel = UILabel().then {
    $0.numberOfLines = Metrics.titleMaxLines
    $0.font = Fonts.title
    $0.textColor = UIColor.grey900
  }

  private let descriptionLabel = UILabel().then {
    $0.numberOfLines = Metrics.descMaxLines
    $0.font = Fonts.desc
    $0.textColor = UIColor.grey500
  }

  private let providerView = VideoProviderView()

  private var imageHeightConstraint: Constraint?

  class func viewHeight(fits width: CGFloat, webpage: CHWebPage) -> CGFloat {
    var height: CGFloat = 0
    height += webpage.thumbUrl != nil ?
      Metrics.imageHeight + Metrics.imageViewBottom : 0
    
    height += Metrics.componentInSectionTop
    if let title = webpage.title {
      height += title.height(
        fits: width - Metrics.sectionBarTrailing - Metrics.sectionBarWidth,
        font: Fonts.title, maximumNumberOfLines: Metrics.titleMaxLines
      )
    }
    if let description = webpage.desc {
      height += webpage.title != nil ? Metrics.descTop : 0
      let text = description.addLineHeight(height: 17, font: Fonts.desc, color: .grey500)
      height += text.height(
        fits: width - Metrics.sectionBarTrailing - Metrics.sectionBarWidth,
        maximumNumberOfLines: Metrics.descMaxLines
      )
    }
    
    if webpage.publisher != nil {
      height += (webpage.title != nil || webpage.desc != nil) ?
        Metrics.providerTop : 0
      height += Metrics.providerHeight
    }
    height += Metrics.componentInSectionBottom

    return height
  }

  override func initialize() {
    super.initialize()

    self.addSubview(self.imageView)
    self.addSubview(self.videoView)
    self.addSubview(self.sectionBar)
    self.infoStackView.addArrangedSubview(self.titleLabel)
    self.infoStackView.addArrangedSubview(self.descriptionLabel)
    self.infoStackView.addArrangedSubview(self.providerView)
    self.addSubview(self.infoStackView)
    
    if #available(iOS 11.0, *) {
      self.infoStackView.setCustomSpacing(8, after: self.descriptionLabel)
    }
  }

  override func setLayouts() {
    super.setLayouts()

    self.imageView.snp.makeConstraints { make in
      self.imageHeightConstraint = make.height.equalTo(0).constraint
      make.width.equalToSuperview()
      make.leading.equalToSuperview()
      make.top.equalToSuperview()
      make.trailing.equalToSuperview()
    }

    self.videoView.snp.makeConstraints { make in
      make.width.equalToSuperview()
      make.leading.equalToSuperview()
      make.top.equalToSuperview()
      make.trailing.equalToSuperview()
      make.height.equalTo(self.imageView.snp.height)
    }

    self.sectionBar.snp.makeConstraints { make in
      make.width.equalTo(Metrics.sectionBarWidth)
      make.leading.equalToSuperview()
      make.top.equalTo(self.imageView.snp.bottom).offset(Metrics.imageViewBottom)
      make.bottom.equalTo(self.infoStackView.snp.bottom)
        .inset(Metrics.componentInSectionBottom)
    }
    
    self.infoStackView.snp.makeConstraints { make in
      make.top.equalTo(self.sectionBar.snp.top).offset(Metrics.componentInSectionTop)
      make.leading.equalTo(self.sectionBar.snp.trailing)
        .offset(Metrics.sectionBarTrailing)
      make.trailing.equalToSuperview()
    }

    self.providerView.snp.makeConstraints { make in
      make.height.equalTo(Metrics.providerHeight)
    }
  }

  func configure(with webPage: CHWebPage, mkInfo: MarketingInfo? = nil) {
    self.titleLabel.text = webPage.title
    self.descriptionLabel.text = webPage.desc
    
    if webPage.isPlayable {
      self.videoView.configure(with: webPage, mkInfo: mkInfo)
      self.videoView.isHidden = false
      self.imageView.isHidden = true
    } else if let url = webPage.thumbUrl {
      self.imageView.sd_setImage(with: url)
      self.imageView.isHidden = false
      self.videoView.isHidden = true
    }
    
    self.providerView.isHidden = webPage.publisher == nil
    self.providerView.configure(publisher: webPage.publisher, title: webPage.author)
    
    self.imageHeightConstraint?.update(offset: webPage.thumbUrl == nil ? 0 : Metrics.imageHeight)
  }
  
  func configure(message: CHMessage) {
    guard let webPage = message.webPage else { return }
    self.configure(with: webPage, mkInfo: message.mkInfo)
  }
}
