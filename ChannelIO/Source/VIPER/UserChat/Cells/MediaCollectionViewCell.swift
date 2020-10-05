//
//  MediaCollectionViewCell.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/16.
//

//import RxSwift
import UIKit

class MediaCollectionViewCell: BaseCollectionViewCell {
  let containerView = UIView()
  let imageView = _ChannelIO_SDAnimatedImageView().then {
    $0.backgroundColor = .white
    $0.contentMode = .scaleAspectFit
    $0._ChannelIO_sd_imageIndicator = _ChannelIO_SDWebImageActivityIndicator.white
  }

  let videoView = VideoPlayerView().then {
    $0.isHidden = true
  }

  private var disposeBag = _RXSwift_DisposeBag()
  private var model: FileCellModel?

  override func initialize() {
    super.initialize()
    self.contentView.addSubview(self.containerView)
    self.containerView.addSubview(self.imageView)
    self.containerView.addSubview(self.videoView)
    
    self.clipsToBounds = true
    self.layer.cornerRadius = 6.f
    self.layer.borderColor = UIColor.grey300.cgColor
    self.layer.borderWidth = 1

    self.videoView.delegate = self
  }

  override func setLayouts() {
    super.setLayouts()
    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.videoView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    self.videoView.prepareForReuse()
  }

  func configure(with model: FileCellModel) {
    guard model.type == .image || model.type == .video else {
      return
    }
    
    self.model = model
    self.imageView.isHidden = model.type == .video
    self.videoView.isHidden = model.type != .video
    self.videoView.observeNotificationIfNeeded(model: model)

    switch model.type {
    case .image:
      self.imageView.sd_setImage(with: model.thumbUrl) { _, error, _, _ in
        if let error = error {
          dlog("CollectionView setImage error: \(error.localizedDescription), thumbUrl: \(String(describing: model.thumbUrl))")
        }
      }
    case .video:
      self.videoView.configure(with: model, mkInfo: model.mkInfo)
    default:
      break
    }
  }
}

extension MediaCollectionViewCell: VideoPlayerDelegate {
  func didFinish() {
    if let model = self.model {
      self.videoView.configure(with: model, mkInfo: model.mkInfo)
    }
  }
}

