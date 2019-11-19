//
//  VideoPlayerView.swift
//  Alamofire
//
//  Created by Jam on 2019/12/16.
//

import AVKit
import RxSwift
import SDWebImage
import UIKit

protocol VideoPlayerDelegate: class {
  func didFinish()
}

class VideoPlayerView: BaseView {
  private let containerView = UIView()
  private let imageView = SDAnimatedImageView().then {
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 6.f
    $0.layer.borderColor = UIColor.grey300.cgColor
    $0.layer.borderWidth = 1
    $0.backgroundColor = .dark20
    $0.contentMode = .scaleAspectFill

    $0.sd_imageIndicator = SDWebImageActivityIndicator.white
  }
  private let playButton = UIImageView().then {
    $0.image = CHAssets.getImage(named: "buttonPlay")
    $0.contentMode = .scaleAspectFit
    $0.isHidden = true
  }
  private let durationView = PlayDurationView()

  private var player: AVPlayer?
  private var playerController = AVPlayerViewController().then {
    $0.showsPlaybackControls = true
  }
  private var playSignal = PublishSubject<(Bool, Double)>()
  private var url: URL?
  private var currSeconds: Double? = 0.0

  var disposeBag = DisposeBag()
  var disposable: Disposable?
  weak var delegate: VideoPlayerDelegate?

  override func initialize() {
    super.initialize()
    self.containerView.addSubview(self.imageView)
    self.containerView.addSubview(self.playButton)
    self.containerView.addSubview(self.durationView)
    self.containerView.addSubview(self.playerController.view)
    self.addSubview(self.containerView)

    self.playButton.rxForClick()
      .subscribe(onNext: { [weak self] _ in
        self?.play(with: self?.url, at: self?.currSeconds)
        self?.setVisibilityOfViews(isPlaying: true)
      }).disposed(by: self.disposeBag)
  }

  func prepareForReuse() {
    self.disposable?.dispose()
  }

  override func setLayouts() {
    super.setLayouts()

    self.playerController.view.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.playButton.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }

    self.durationView.snp.makeConstraints { make in
      make.height.equalTo(28)
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
  }

  func observeNotificationIfNeeded(model: VideoPlayable) {
    self.disposable?.dispose()

    if model.isPlayable {
      self.disposable = NotificationCenter.default.rx
        .notification(
          NSNotification.Name.AVPlayerItemDidPlayToEndTime,
          object: self.player?.currentItem
        )
        .subscribe(onNext: { [weak self] notification in
          guard
            let self = self,
            let item = notification.object as? AVPlayerItem,
            let currItem = self.player?.currentItem,
            item == currItem else { return }
          self.setPlayItem(with: self.url)
          self.setVisibilityOfViews(isPlaying: false)
          self.playSignal.onNext((false, 0))
        })
    }
  }

  func configure(with model: VideoPlayable & ThumbDisplayable) {
    guard let url = model.url else { return }
    self.url = url
    self.currSeconds = model.currSeconds

    self.setVisibilityOfViews(isPlaying: false)
    self.imageView.sd_setImage(with: model.thumbUrl)
    self.durationView.configure(with: PlayDurationModel(duration: model.duration))

    let item = AVPlayerItem(url: url)

    if self.player != nil {
      self.player?.pause()
      self.player?.replaceCurrentItem(with: item)
    } else {
      let player = self.getPlayer(with: item)
      self.playerController.player = player
    }
  }

  func play(with url: URL? = nil, at seconds: Double? = nil) {
    self.setPlayItem(with: url ?? self.url)
    if let seconds = seconds {
      self.player?.seek(to: CMTime(seconds: seconds, preferredTimescale: 1))
    } else {
      self.player?.seek(to: CMTime(seconds: self.currSeconds ?? 0, preferredTimescale: 1))
    }
    self.player?.play()
  }

  func pause() {
    self.player?.pause()
  }

  func willDisplay(in controller: UIViewController) {
    controller.addChild(self.playerController)
    self.playerController.didMove(toParent: controller)
  }

  func didHide(from controller: UIViewController) {
    self.pause()
    self.setVisibilityOfViews(isPlaying: false)
    self.playerController.willMove(toParent: nil)
    self.playerController.removeFromParent()
    self.disposable?.dispose()
  }

  func signalForPlay() -> Observable<(Bool, Double)> {
    self.playSignal = PublishSubject<(Bool, Double)>()
    return self.playSignal.asObservable()
  }

  private func setVisibilityOfViews(isPlaying: Bool) {
    self.imageView.isHidden = isPlaying
    self.playButton.isHidden = isPlaying
    self.durationView.isHidden = isPlaying
    self.playerController.view.isHidden = !isPlaying
  }

  private func setPlayItem(with url: URL? = nil) {
    if let url = url {
      let item = AVPlayerItem(url: url)
      self.playerController.player?.replaceCurrentItem(with: item)
    }
  }

  private func getPlayer(with item: AVPlayerItem) -> AVPlayer {
    if let player = self.player {
      return player
    }

    let player = AVPlayer(playerItem: item)
    player.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
    self.player = player
    return player
  }

  override func observeValue(
    forKeyPath keyPath: String?,
    of object: Any?,
    change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?) {
    let currSeconds = self.player?.currentTime().seconds ?? 0.0
    if keyPath == "rate" && (change?[NSKeyValueChangeKey.newKey] as? Float) == 0 {
      self.playSignal.onNext((false, currSeconds))
    } else if keyPath == "rate" && (change?[NSKeyValueChangeKey.newKey] as? Float) == 1 {
      self.playSignal.onNext((true, currSeconds))
    }
  }
}

