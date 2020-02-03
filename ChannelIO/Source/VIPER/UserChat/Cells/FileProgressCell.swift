//
//  FileStatusCell.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/06.
//

import SnapKit
import RxCocoa
import RxSwift


class FileStatusCell: BaseTableViewCell {
  private struct Constants {
    static let containerViewLeading = 10.f
    static let containerViewTrailing = 2.f
    static let middleStackViewLeading = 10.f
    static let thumbViewSide = 40.f
    static let fileStateViewLeading = 12.f
    static let errorButtonSide = 38.f
    static let deleteButtonSide = 44.f
    static let labelMinWidth = 43.f
  }
  
  private let containerStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.spacing = 10.f
  }
  
  private var thumbImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 3.f
  }
  
  private let middleStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 6.f
  }
  
  private let textContainerView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 6.f
    $0.distribution = .fill
  }
  
  private var countLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 12)
    $0.textAlignment = .right
    $0.textColor = CHColors.blueyGrey
  }
  
  private var fileNameLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textAlignment = .left
    $0.textColor = CHColors.charcoalGrey
  }
  
  private var progressView = UIProgressView().then {
    $0.clipsToBounds = true
    $0.trackTintColor = .black10
    $0.progressTintColor = .cobalt400
    $0.transform = CGAffineTransform(scaleX: 1.f, y: 3.f)
    $0.layer.cornerRadius = 4.f
  }
  
  private let errorButton = UIButton().then {
    $0.setImage(CHAssets.getImage(named: "refreshCircleFilled"), for: .normal)
    $0.isHidden = true
  }
  
  private let removebutton = UIButton().then {
    $0.setImage(CHAssets.getImage(named: "cancelSmall.png"), for: .normal)
  }
  
  private var removeSignal = PublishRelay<Any?>()
  private var retrySignal = PublishRelay<Any?>()

  override func initialize() {
    super.initialize()
    
    self.containerStackView.addArrangedSubview(self.thumbImageView)
    self.containerStackView.addArrangedSubview(self.middleStackView)
    self.containerStackView.addArrangedSubview(self.errorButton)
    self.containerStackView.addArrangedSubview(self.removebutton)
    
    self.textContainerView.addArrangedSubview(self.fileNameLabel)
    self.textContainerView.addArrangedSubview(self.countLabel)
    
    self.middleStackView.addArrangedSubview(self.textContainerView)
    self.middleStackView.addArrangedSubview(self.progressView)
    
    self.contentView.addSubview(self.containerStackView)
  }

  override func setLayouts() {
    super.setLayouts()
    
    self.containerStackView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(Constants.containerViewLeading)
      make.trailing.equalToSuperview().inset(Constants.containerViewTrailing)
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    self.countLabel.snp.makeConstraints { (make) in
      make.width.greaterThanOrEqualTo(Constants.labelMinWidth)
    }
    
    self.progressView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    
    self.thumbImageView.snp.makeConstraints { (make) in
      make.width.equalTo(Constants.thumbViewSide)
      make.height.equalTo(Constants.thumbViewSide)
    }
    
    self.errorButton.snp.makeConstraints { (make) in
      make.width.equalTo(Constants.errorButtonSide)
    }
    
    self.removebutton.snp.makeConstraints { (make) in
      make.width.equalTo(Constants.deleteButtonSide)
    }
  }
  
  private func displayStatus(with item: ChatFileQueueItem) {
    if item.status == .error {
      self.errorButton.isHidden = false
      self.progressView.isHidden = true
      self.displayName(with: CHAssets.localized("file_upload.fail"))
    } else if item.status == .progress {
      self.errorButton.isHidden = true
      self.progressView.isHidden = false
      self.progressView.setProgress(Float(item.progress), animated: false)
      self.displayName(with: item.name)
      
      if item.progress == 1 {
        self.progressView.startShimmeringAnimation(animationSpeed: 4.0)
      } else {
        self.progressView.stopShimmeringAnimation()
      }
    }
  }
  
  private func displayThumb(with item: ChatFileQueueItem) {
    if item.fileType == .image, let data = item.data {
      self.thumbImageView.image = UIImage(data: data)
    } else {
      self.thumbImageView.image = CHAssets.getImage(named: "pdf")
    }
  }
  
  private func displayCount(with count: Int) {
    self.countLabel.isHidden = count == 0
    self.countLabel.text = String(
      format: CHAssets.localized("file_upload.wait_count"), "\(count)"
    )
  }
  
  private func displayName(with name: String) {
    self.fileNameLabel.text = name
  }

  func configure(item: ChatFileQueueItem, count: Int) {
    self.displayStatus(with: item)
    self.displayThumb(with: item)
    self.displayCount(with: count)
  }
  
  func signalForRemove() -> PublishRelay<Any?> {
    self.removeSignal = PublishRelay<Any?>()
    self.removebutton
      .signalForClick()
      .bind(to: self.removeSignal)
      .disposed(by: self.disposeBag)
    return self.removeSignal
  }

  func signalForRetry() -> PublishRelay<Any?> {
    self.retrySignal = PublishRelay<Any?>()
    self.errorButton
      .signalForClick()
      .bind(to: self.retrySignal)
      .disposed(by: self.disposeBag)
    return self.retrySignal
  }
}
