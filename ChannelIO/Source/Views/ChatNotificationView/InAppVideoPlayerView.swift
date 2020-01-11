//
//  VideoPlayerView.swift
//  ChannelIO
//
//  Created by R3alFr3e on 12/31/19.
//  Copyright © 2019 ZOYI. All rights reserved.
//
import AVKit
import RxSwift
import SDWebImage
import UIKit

class InAppVideoPlayerView: BaseView {
  private struct Metrics {
    static let volumeImageLength = 24.f
    static let volumeImagePadding = 10.f
    static let volumeControlViewLength = 44.f
  }
  
  private let containerView = UIView()

  private var player: AVPlayer?
  private let playerLayer = AVPlayerLayer().then {
    $0.videoGravity = .resizeAspectFill
    $0.needsDisplayOnBoundsChange = true
  }
  
  private var controlView = UIView()
  private var volumeImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "volumeOffFilled")
  }
  
  private let volumeOffImage = CHAssets.getImage(named: "volumeOffFilled")
  private let volumeUpImage = CHAssets.getImage(named: "volumeUpFilled")
  
  var disposeBag = DisposeBag()

  override func initialize() {
    super.initialize()
    
    self.containerView.layer.addSublayer(self.playerLayer)
    self.controlView.addSubview(self.volumeImageView)
    self.addSubview(self.containerView)
    self.addSubview(self.controlView)

    self.controlView
      .signalForClick()
      .subscribe(onNext: { [weak self] _ in
        guard let isMuted = self?.player?.isMuted else { return }
        self?.player?.isMuted = !isMuted
        self?.volumeImageView.image = isMuted ?
          self?.volumeUpImage : self?.volumeOffImage
      }).disposed(by: self.disposeBag)
  }

  override func setLayouts() {
    super.setLayouts()

    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.volumeImageView.snp.makeConstraints { make in
      make.bottom.trailing.equalToSuperview().inset(Metrics.volumeImagePadding)
      make.width.equalTo(Metrics.volumeImageLength)
      make.height.equalTo(Metrics.volumeImageLength)
    }
    
    self.controlView.snp.makeConstraints { make in
      make.bottom.trailing.equalToSuperview()
      make.width.equalTo(Metrics.volumeControlViewLength)
      make.height.equalTo(Metrics.volumeControlViewLength)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.playerLayer.frame = self.containerView.bounds
  }
  
  func configure(with url: URL?, controlEnable: Bool) {
    guard let url = url else { return }
    
    self.controlView.isHidden = !controlEnable
    
    let item = AVPlayerItem(url: url)
    let player = self.getPlayer(with: item)
    if self.playerLayer.player == nil {
      self.playerLayer.player = player
    }
    player.play()
    player.isMuted = true
    self.volumeImageView.image = self.volumeOffImage
  }

  func pause() {
    guard let player = player else { return }
    player.pause()
  }

  func play() {
    guard let player = self.player else { return }
    player.play()
  }

  private func getPlayer(with item: AVPlayerItem) -> AVPlayer {
    if let player = self.player {
      player.replaceCurrentItem(with: item)
      return player
    }

    let player = AVPlayer(playerItem: item)
    self.player = player
    return player
  }
}
