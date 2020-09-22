//
//  VideoPlayerView.swift
//  ChannelIO
//
//  Created by R3alFr3e on 12/31/19.
//  Copyright © 2019 ZOYI. All rights reserved.
//
import AVKit
import RxSwift
import UIKit

class InAppVideoPlayerView: BaseView {
  private let containerView = UIView()

  private var player: AVPlayer?
  private let playerLayer = AVPlayerLayer().then {
    $0.videoGravity = .resizeAspectFill
    $0.needsDisplayOnBoundsChange = true
  }
  
  private let progressBar = UIProgressView().then {
    $0.clipsToBounds = true
    $0.trackTintColor = .black40
    $0.progressTintColor = .white
    $0.transform = CGAffineTransform(scaleX: 1.f, y: 3.f)
    $0.progress = 0
  }
  
  var disposeBag = DisposeBag()

  override func initialize() {
    super.initialize()
    
    self.containerView.layer.addSublayer(self.playerLayer)
    self.addSubview(self.containerView)
    self.addSubview(self.progressBar)
  }

  override func setLayouts() {
    super.setLayouts()

    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.progressBar.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.playerLayer.frame = self.containerView.bounds
  }
  
  func configure(with url: URL?) {
    guard let url = url else { return }
    
    let item = AVPlayerItem(url: url)
    let player = self.getPlayer(with: item)
    if self.playerLayer.player == nil {
      self.playerLayer.player = player
    }
    player.play()
    player.isMuted = true
    
    self.player?.addPeriodicTimeObserver(
      forInterval: CMTime.init(value: 1, timescale: 50),
      queue: .main,
      using: { [weak self] time in
      if let duration = self?.player?.currentItem?.duration {
        let progress = (CMTimeGetSeconds(time) / CMTimeGetSeconds(duration))
        self?.progressBar.setProgress(progress.isNaN ? 0 : Float(progress), animated: !progress.isNaN)
      }
    })
  }
  
  func toggleMute() {
    guard let isMuted = self.player?.isMuted else { return }
    self.player?.isMuted = !isMuted
  }
  
  func isMuted() -> Bool? {
    guard let isMuted = self.player?.isMuted else { return nil }
    return isMuted
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
