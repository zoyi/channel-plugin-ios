//
//  VideoProviderView.swift
//  ChannelIO
//
//  Created by intoxicated on 11/12/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

class VideoProviderView: BaseView {
  private struct Metrics {
    static let imageViewSide = 16.f
    static let dividerWidth = 1.f
    static let dividerHeight = 14.f
  }
  
  private let containerStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 6.f
  }
  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  private let providerLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 12)
    $0.textColor = .grey700
  }
  private let dividerContainerView = UIView()
  private let dividerView = UIView().then {
    $0.backgroundColor = .grey300
  }
  private let titleLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 12)
    $0.textColor = .grey700
  }

  override func initialize() {
    super.initialize()
    self.containerStackView.addArrangedSubview(self.imageView)
    self.containerStackView.addArrangedSubview(self.providerLabel)
    self.dividerContainerView.addSubview(self.dividerView)
    self.containerStackView.addArrangedSubview(self.dividerContainerView)
    self.containerStackView.addArrangedSubview(self.titleLabel)
    self.addSubview(self.containerStackView)
  }

  override func setLayouts() {
    super.setLayouts()

    self.containerStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.imageView.snp.makeConstraints { make in
      make.width.equalTo(Metrics.imageViewSide)
      make.height.equalTo(Metrics.imageViewSide)
    }

    self.dividerView.snp.makeConstraints { make in
      make.width.equalTo(Metrics.dividerWidth)
      make.height.equalTo(Metrics.dividerHeight)
      make.centerY.equalToSuperview()
    }
  }

  func configure(publisher: VideoPublisher?, title: String?) {
    self.imageView.image = publisher?.image
    self.providerLabel.text = publisher?.name
    self.titleLabel.text = title
  }
}
