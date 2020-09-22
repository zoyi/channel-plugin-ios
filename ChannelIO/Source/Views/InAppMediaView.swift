//
//  InAppMediaView.swift
//  ChannelIO
//
//  Created by R3alFr3e on 12/31/19.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import RxSwift

class InAppMediaView: BaseView {
  private struct Metrics {
    static let bannerHeight = 72.f
    static let popupWidth = 320.f
    static let maxRatio = 16.f / 9.f
    static let minRatio = 1.f
    static let multiIndicatorBannerSide = 4.f
    static let multiIndicatorPopupSide = 4.f
    static let volumeImageLength = 24.f
    static let volumeImagePadding = 10.f
    static let volumeControlViewLength = 44.f
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .center
  }
  
  private let imageView = _ChannelIO_SDAnimatedImageView().then {
    $0.backgroundColor = .dark20
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true

    $0._ChannelIO_sd_imageIndicator = _ChannelIO_SDWebImageActivityIndicator.white
  }

  private let multiIndicatorView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "squaresFilled")
  }

  private let videoView = InAppVideoPlayerView().then {
    $0.layer.borderColor = UIColor.grey300.cgColor
    $0.layer.borderWidth = 1
    $0.backgroundColor = .dark20
  }
  
  private let youtubePlayerView = YoutubePlayerView().then {
    $0.isUserInteractionEnabled = false
  }
  private let youtubeParams = [
    "controls": 0,
    "modestbranding": 0,
    "playsinline": 1,
    "rel": 1,
    "showinfo": 0,
    "autoplay": 1
  ]
  
  private var controlView = UIView()
  private var volumeImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "volumeOffFilled")
  }
  private let volumeOffImage = CHAssets.getImage(named: "volumeOffFilled")
  private let volumeUpImage = CHAssets.getImage(named: "volumeUpFilled")
  private var mkInfo: MarketingInfo?
  
  private var imageWidthConstraint: Constraint?
  private var videoWidthConstraint: Constraint?
  private var youtubeWidthConstraint: Constraint?
  private var imageHeightConstraint: Constraint?
  private var videoHeightConstraint: Constraint?
  private var youtubeHeightConstraint: Constraint?
  private var multiIndicatorConstraint: Constraint?
  
  private var disposeBag = DisposeBag()

  override func initialize() {
    super.initialize()
    
    self.containerView.addArrangedSubview(self.imageView)
    self.containerView.addArrangedSubview(self.videoView)
    self.containerView.addArrangedSubview(self.youtubePlayerView)
    self.controlView.addSubview(self.volumeImageView)
    self.addSubview(self.containerView)
    self.addSubview(self.multiIndicatorView)
    self.addSubview(self.controlView)
    
    self.youtubePlayerView.delegate = self
    
    self.controlView
      .signalForClick()
      .subscribe(onNext: { [weak self] _ in
        if let mkInfo = self?.mkInfo {
          mainStore.dispatch(ClickMarketing(type: mkInfo.type, id: mkInfo.id))
        }
        if self?.videoView.isHidden == false {
          self?.volumeImageView.image = self?.videoView.isMuted() == true ?
            self?.volumeUpImage : self?.volumeOffImage
          self?.videoView.toggleMute()
        } else if self?.youtubePlayerView.isHidden == false {
          self?.youtubePlayerView.isMuted() { isMuted in
            self?.volumeImageView.image = isMuted == true ?
              self?.volumeUpImage : self?.volumeOffImage
          }
          self?.youtubePlayerView.toggleMute()
        }
      }).disposed(by: self.disposeBag)
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
      self.multiIndicatorConstraint = make.top.trailing.equalToSuperview()
        .inset(Metrics.multiIndicatorPopupSide).constraint
    }
    
    self.volumeImageView.snp.makeConstraints { make in
      make.bottom.leading.equalToSuperview().inset(Metrics.volumeImagePadding)
      make.width.equalTo(Metrics.volumeImageLength)
      make.height.equalTo(Metrics.volumeImageLength)
    }
    
    self.controlView.snp.makeConstraints { make in
      make.bottom.leading.equalToSuperview()
      make.width.equalTo(Metrics.volumeControlViewLength)
      make.height.equalTo(Metrics.volumeControlViewLength)
    }
  }

  func configure(model: InAppNotificationViewModel) {
    guard
      (!model.files.isEmpty || model.webPage != nil) else {
      self.setVisibilityForViews(type: model.mobileExposureType)
      return
    }
    self.mkInfo = model.mkInfo
    
    let isBanner = model.mobileExposureType == .banner
    self.containerView.axis = isBanner ? .horizontal : .vertical
    self.containerView.alignment = isBanner ? .center : .fill
    let multiIndicatorMargin = isBanner ?
      Metrics.multiIndicatorBannerSide :
      Metrics.multiIndicatorPopupSide
    
    self.multiIndicatorConstraint?.update(inset: multiIndicatorMargin)
    
    if !model.files.isEmpty {
      self.displayFiles(with: model.files, type: model.mobileExposureType)
    } else if let webPage = model.webPage {
      self.displayWebPage(with: webPage, type: model.mobileExposureType)
    }
  }
  
  private func displayFiles(with files: [CHFile], type: InAppNotificationType) {
    let videos = files.filter { $0.type == .video }
    let images = files.filter { $0.type == .image }

    if let video = videos.first, let url = video.url {
      self.videoView.configure(with: url)
      self.updateFileLayout(type: type, file: video)
    } else if  let image = images.first, let url = image.url {
      self.imageView.sd_setImage(with: url)
      self.updateFileLayout(type: type, file: image)
    }
    
    self.multiIndicatorView.isHidden = videos.count + images.count <= 1
    self.setVisibilityForViews(file: videos.first ?? images.first, type: type)
  }
  
  private func displayWebPage(with webPage: CHWebPage, type: InAppNotificationType) {
    if webPage.isPlayable, let youtubeId = webPage.youtubeId {
      self.youtubePlayerView.loadWithVideoId(youtubeId, with: self.youtubeParams)
    } else if let url = webPage.thumbUrl {
      self.imageView.sd_setImage(with: url)
    }
    
    self.updateWebLayout(webPage: webPage, type: type)
    self.setVisibilityForViews(webPage: webPage, type: type)
  }
  
  private func updateFileLayout(type: InAppNotificationType, file: CHFile) {
    if file.type == .video, file.url != nil {
      if type == .banner {
        self.videoWidthConstraint?.update(offset: self.getRatio(
          width: file.width.f, height: file.height.f, type: .banner) * Metrics.bannerHeight
        ).activate()
        self.videoHeightConstraint?.update(offset: Metrics.bannerHeight).activate()
      } else if type == .fullScreen {
        self.videoWidthConstraint?.update(offset: Metrics.popupWidth).activate()
        self.videoHeightConstraint?.update(offset: self.getRatio(
          width: file.width.f, height: file.height.f, type: .fullScreen) * Metrics.popupWidth
        ).activate()
      }
    } else if file.type == .image, file.thumbUrl != nil {
      if type == .banner {
        self.imageWidthConstraint?.update(offset: self.getRatio(
          width: file.width.f, height: file.height.f, type: .banner) * Metrics.bannerHeight
        ).activate()
        self.imageHeightConstraint?.update(offset: Metrics.bannerHeight).activate()
      } else if type == .fullScreen {
        self.imageWidthConstraint?.update(offset: Metrics.popupWidth).activate()
        self.imageHeightConstraint?.update(offset: self.getRatio(
          width: file.width.f, height: file.height.f, type: .fullScreen) * Metrics.popupWidth
        ).activate()
      }
    }
  }
  
  private func updateWebLayout(webPage: CHWebPage, type: InAppNotificationType) {
    if webPage.youtubeId != nil {
      if type == .banner {
        self.youtubeWidthConstraint?.update(offset: self.getRatio(
          width: webPage.width.f, height: webPage.height.f, type: .banner) * Metrics.bannerHeight
        ).activate()
        self.youtubeHeightConstraint?.update(offset: Metrics.bannerHeight).activate()
      } else if type == .fullScreen {
        self.youtubeWidthConstraint?.update(offset: Metrics.popupWidth).activate()
        self.youtubeHeightConstraint?.update(offset: self.getRatio(
          width: webPage.width.f, height: webPage.height.f, type: .fullScreen) * Metrics.popupWidth
        ).activate()
      }
    } else if webPage.thumbUrl != nil {
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
    }
  }
  
  private func setVisibilityForViews(
    file: CHFile? = nil,
    webPage: CHWebPage? = nil,
    type: InAppNotificationType) {
    if file?.type == .video {
      self.imageView.isHidden = true
      self.videoView.isHidden = false
      self.youtubePlayerView.isHidden = true
      self.controlView.isHidden = type == .banner
    } else if file?.type == .image {
      self.imageView.isHidden = false
      self.videoView.isHidden = true
      self.youtubePlayerView.isHidden = true
      self.controlView.isHidden = true
    } else if webPage?.youtubeId != nil {
      self.imageView.isHidden = true
      self.multiIndicatorView.isHidden = true
      self.videoView.isHidden = true
      self.youtubePlayerView.isHidden = false
      self.controlView.isHidden = type == .banner
    } else if webPage?.thumbUrl != nil {
      self.imageView.isHidden = false
      self.multiIndicatorView.isHidden = true
      self.videoView.isHidden = true
      self.youtubePlayerView.isHidden = true
      self.controlView.isHidden = true
    } else {
      self.imageView.isHidden = true
      self.multiIndicatorView.isHidden = true
      self.controlView.isHidden = true
      self.videoView.isHidden = true
      self.youtubePlayerView.isHidden = true
    }
  }

  private func getRatio(
    width: CGFloat,
    height: CGFloat,
    type: InAppNotificationType) -> CGFloat {
    guard height != 0 else { return 1 / Metrics.maxRatio }
    let ratio = width / height
    
    var result = 0.f
    if ratio >= Metrics.maxRatio {
      result = Metrics.maxRatio
    } else if ratio <= Metrics.minRatio {
      result = Metrics.minRatio
    } else {
     result = ratio
    }
    return type == .banner ? result : 1 / result
  }
}

extension InAppMediaView: YoutubePlayerViewDelegate {
  func playerViewDidBecomeReady(_ playerView: YoutubePlayerView) {
    playerView.mute()
  }
}
