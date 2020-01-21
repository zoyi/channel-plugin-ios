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
    static let providerHeight = 22.f
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
  private var sectionBarBottomToProvider: Constraint?
  private var sectionBarBottomToDesc: Constraint?
  private var sectionBarBottomToTitle: Constraint?

  class func viewHeight(fits width: CGFloat, webpage: CHWebPage) -> CGFloat {
    var height: CGFloat = 0
    height += webpage.thumbUrl != nil ? Metrics.imageHeight + Metrics.imageViewBottom : 0
    
    height += Metrics.componentInSectionTop
    if let title = webpage.title {
      height += title.height(
        fits: width - Metrics.sectionBarTrailing - Metrics.sectionBarWidth,
        font: Fonts.title, maximumNumberOfLines: Metrics.titleMaxLines
      )
    }
    if let description = webpage.desc {
      height += Metrics.descTop + description.height(
        fits: width - Metrics.sectionBarTrailing - Metrics.sectionBarWidth,
        font: Fonts.desc, maximumNumberOfLines: Metrics.descMaxLines
      )
    }
    if webpage.publisher != nil {
      height += Metrics.providerTop + Metrics.providerHeight
    }
    height += Metrics.componentInSectionBottom + Metrics.webPageMessageViewBottom

    return height
  }

  override func initialize() {
    super.initialize()

    self.addSubview(self.imageView)
    self.addSubview(self.videoView)
    self.addSubview(self.sectionBar)
    self.addSubview(self.titleLabel)
    self.addSubview(self.descriptionLabel)
    self.addSubview(self.providerView)
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
      self.sectionBarBottomToProvider = make.bottom.equalTo(self.providerView.snp.bottom)
        .offset(Metrics.componentInSectionBottom).constraint
      self.sectionBarBottomToDesc = make.bottom.equalTo(self.descriptionLabel.snp.bottom)
        .offset(Metrics.componentInSectionBottom).priority(850).constraint
      self.sectionBarBottomToTitle = make.bottom.equalTo(self.titleLabel.snp.bottom)
        .offset(Metrics.componentInSectionBottom).priority(700).constraint
      make.top.equalTo(self.imageView.snp.bottom).offset(Metrics.imageViewBottom)
    }

    self.titleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.sectionBar.snp.top).offset(Metrics.componentInSectionTop)
      make.leading.equalTo(self.sectionBar.snp.trailing).offset(Metrics.sectionBarTrailing)
      make.trailing.equalToSuperview()
    }

    self.descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(Metrics.descTop)
      make.leading.equalTo(self.sectionBar.snp.trailing).offset(Metrics.sectionBarTrailing)
      make.trailing.equalToSuperview()
    }

    self.providerView.snp.makeConstraints { make in
      make.height.equalTo(Metrics.providerHeight)
      make.top.equalTo(self.descriptionLabel.snp.bottom).offset(Metrics.providerTop)
      make.leading.equalTo(self.sectionBar.snp.trailing).offset(Metrics.sectionBarTrailing)
      make.trailing.lessThanOrEqualToSuperview()
      make.bottom.equalToSuperview()
    }
  }

  func configure(with webPage: CHWebPage) {
    self.titleLabel.text = webPage.title
    self.descriptionLabel.text = webPage.desc
    
    if webPage.isPlayable {
      self.videoView.configure(with: webPage)
      self.videoView.isHidden = false
      self.imageView.isHidden = true
    } else if let url = webPage.thumbUrl {
      self.imageView.sd_setImage(with: url)
      self.imageView.isHidden = false
      self.videoView.isHidden = true
    }
    
    self.providerView.isHidden = webPage.publisher == nil
    self.providerView.configure(publisher: webPage.publisher, title: webPage.author)
    
    if webPage.publisher != nil {
      self.sectionBarBottomToProvider?.activate()
      self.sectionBarBottomToDesc?.deactivate()
      self.sectionBarBottomToTitle?.deactivate()
    } else if webPage.desc != nil {
      self.sectionBarBottomToProvider?.deactivate()
      self.sectionBarBottomToDesc?.activate()
      self.sectionBarBottomToTitle?.deactivate()
    } else {
      self.sectionBarBottomToProvider?.deactivate()
      self.sectionBarBottomToDesc?.deactivate()
      self.sectionBarBottomToTitle?.activate()
    }
    
    self.imageHeightConstraint?.update(offset: webPage.thumbUrl == nil ? 0 : Metrics.imageHeight)
  }
}
