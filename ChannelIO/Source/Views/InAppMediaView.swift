//
//  InAppMediaView.swift
//  ChannelIO
//
//  Created by R3alFr3e on 12/31/19.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import SDWebImage
import SnapKit
import RxSwift

class InAppMediaView: BaseView {
  private struct Metrics {
    static let bannerHeight = 78.f
    static let popupWidth = 312.f
    static let maxRatio = 16.f / 9.f
    static let minRatio = 1.f
    static let cornerRadius = 8.f
    static let multiIndicatorSide = 4.f
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .center
  }
  
  private let imageView = SDAnimatedImageView().then {
    $0.layer.borderColor = UIColor.grey300.cgColor
    $0.layer.borderWidth = 1
    $0.backgroundColor = .dark20
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true

    $0.sd_imageIndicator = SDWebImageActivityIndicator.white
  }

  private let multiIndicatorView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "squaresFilled")
  }

  private let videoView = InAppVideoPlayerView().then {
    $0.layer.borderColor = UIColor.grey300.cgColor
    $0.layer.borderWidth = 1
    $0.backgroundColor = .dark20
  }
  
  private let youtubePlayerView = YoutubePlayerView()
  private let youtubeParams = [
    "controls": 0,
    "modestbranding": 0,
    "playsinline": 1,
    "rel": 1,
    "showinfo": 0,
    "autoplay": 1
  ]
  
  private var imageWidthConstraint: Constraint?
  private var videoWidthConstraint: Constraint?
  private var youtubeWidthConstraint: Constraint?
  
  private var imageHeightConstraint: Constraint?
  private var videoHeightConstraint: Constraint?
  private var youtubeHeightConstraint: Constraint?
  
  private var disposeBag = DisposeBag()

  override func initialize() {
    super.initialize()
    
    self.containerView.addArrangedSubview(self.imageView)
    self.containerView.addArrangedSubview(self.videoView)
    self.containerView.addArrangedSubview(self.youtubePlayerView)
    self.addSubview(self.containerView)
    self.addSubview(self.multiIndicatorView)
    
    self.youtubePlayerView.delegate = self
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.imageView.snp.makeConstraints { make in
      self.imageWidthConstraint = make.width.equalTo(0).constraint
      self.imageHeightConstraint = make.height.equalTo(0).constraint
    }
    
    self.videoView.snp.makeConstraints { make in
      self.videoWidthConstraint = make.width.equalTo(0).constraint
      self.videoHeightConstraint = make.height.equalTo(0).constraint
    }
    
    self.youtubePlayerView.snp.makeConstraints { make in
      self.youtubeWidthConstraint = make.width.equalTo(0).constraint
      self.youtubeHeightConstraint = make.height.equalTo(0).constraint
    }
    
    self.multiIndicatorView.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(Metrics.multiIndicatorSide)
    }
  }

  private func getRatio(
    width: CGFloat,
    height: CGFloat,
    type: InAppNotificationType) -> CGFloat {
    let ratio = type == .banner ? width / height : height / width
    let maxRatio = type == .banner ? Metrics.maxRatio : 1 / Metrics.maxRatio
    
    if ratio > maxRatio {
      return type == .banner ? maxRatio : Metrics.minRatio
    } else if ratio < Metrics.minRatio {
      return type == .banner ? Metrics.minRatio : maxRatio
    } else {
      return ratio
    }
  }

  func configure(model: InAppNotificationViewModel) {
    guard
      (!model.files.isEmpty || model.webPage != nil) else {
      self.hideAll()
      return
    }

    self.containerView.axis = model.mobileExposureType == .banner ?
      .horizontal : .vertical
    self.containerView.alignment = model.mobileExposureType == .banner ?
      .center : .fill
    self.layer.cornerRadius = model.mobileExposureType == .banner ?
      0.f : Metrics.cornerRadius
    
    if !model.files.isEmpty {
      self.displayFiles(with: model.files, type: model.mobileExposureType)
    } else if let webPage = model.webPage {
      self.displayWebPage(with: webPage, type: model.mobileExposureType)
    }
  }
  
  private func displayFiles(with files: [CHFile], type: InAppNotificationType) {
    let videos = files.filter { $0.type == .video }
    let images = files.filter { $0.type == .image }
    let mediaCount = videos.count + images.count
    
    if let video = videos.first, let url = video.url {
      self.imageView.isHidden = true
      self.multiIndicatorView.isHidden = mediaCount <= 1
      self.videoView.isHidden = false
      self.youtubePlayerView.isHidden = true
      if type == .banner {
        self.videoWidthConstraint?.update(offset: self.getRatio(
          width: video.width.f, height: video.height.f, type: .banner) * Metrics.bannerHeight
        ).activate()
        self.videoHeightConstraint?.update(offset: Metrics.bannerHeight).activate()
        self.videoView.configure(with: url, controlEnable: false)
      } else if type == .fullScreen {
        self.videoWidthConstraint?.update(offset: Metrics.popupWidth).activate()
        self.videoHeightConstraint?.update(offset: self.getRatio(
          width: video.width.f, height: video.height.f, type: .fullScreen) * Metrics.popupWidth
        ).activate()
        self.videoView.configure(with: url, controlEnable: true)
      }
    } else if  let image = images.first , let url = image.url {
      self.imageView.isHidden = false
      self.multiIndicatorView.isHidden = mediaCount <= 1
      self.videoView.isHidden = true
      self.youtubePlayerView.isHidden = true
      if type == .banner {
        self.imageWidthConstraint?.update(offset: self.getRatio(
          width: image.width.f, height: image.height.f, type: .banner) * Metrics.bannerHeight
        ).activate()
        self.imageHeightConstraint?.update(offset: Metrics.bannerHeight).activate()
      } else if type == .fullScreen {
        self.imageWidthConstraint?.update(offset: Metrics.popupWidth).activate()
        self.imageHeightConstraint?.update(offset: self.getRatio(
          width: image.width.f, height: image.height.f, type: .fullScreen) * Metrics.popupWidth
        ).activate()
      }
      self.imageView.sd_setImage(with: url)
    } else {
      self.hideAll()
    }
  }
  
  private func displayWebPage(
    with webPage: CHWebPage,
    type: InAppNotificationType) {
    if webPage.isPlayable, let youtubeId = webPage.youtubeId {
      self.imageView.isHidden = true
      self.multiIndicatorView.isHidden = true
      self.videoView.isHidden = true
      self.youtubePlayerView.isHidden = false
      
      if type == .banner {
        self.youtubeWidthConstraint?.update(offset: self.getRatio(
          width: webPage.width.f, height: webPage.height.f, type: .banner) * Metrics.bannerHeight
        ).activate()
        self.youtubeHeightConstraint?.update(offset: Metrics.bannerHeight).activate()
        self.youtubePlayerView.isUserInteractionEnabled = false
      } else if type == .fullScreen {
        self.youtubeWidthConstraint?.update(offset: Metrics.popupWidth).activate()
        self.youtubeHeightConstraint?.update(offset: self.getRatio(
          width: webPage.width.f, height: webPage.height.f, type: .fullScreen) * Metrics.popupWidth
        ).activate()
        self.youtubePlayerView.isUserInteractionEnabled = true
      }
      self.youtubePlayerView.loadWithVideoId(youtubeId, with: self.youtubeParams)
    } else if let url = webPage.thumbUrl {
      self.imageView.isHidden = false
      self.multiIndicatorView.isHidden = true
      self.videoView.isHidden = true
      self.youtubePlayerView.isHidden = true
      
      if type == .banner {
        self.imageWidthConstraint?.update(offset: self.getRatio(
          width: webPage.width.f, height: webPage.height.f, type: .banner) * Metrics.bannerHeight
        ).activate()
        self.imageHeightConstraint?.update(offset: Metrics.bannerHeight).activate()
      } else if type == .fullScreen {
        self.imageWidthConstraint?.update(offset: Metrics.popupWidth).activate()
        self.imageHeightConstraint?.update(offset: self.getRatio(
          width: webPage.width.f, height: webPage.height.f, type: .fullScreen) * Metrics.popupWidth
        ).activate()
      }
      self.imageView.sd_setImage(with: url)
    } else {
      self.hideAll()
    }
  }
  
  private func hideAll() {
    self.imageView.isHidden = true
    self.multiIndicatorView.isHidden = true
    self.videoView.isHidden = true
    self.youtubePlayerView.isHidden = true
  }
}

extension InAppMediaView: YoutubePlayerViewDelegate {
  func playerViewDidBecomeReady(_ playerView: YoutubePlayerView) {
    playerView.mute()
  }
}
