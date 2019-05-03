//
//  LoungeExternalAppsView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 25/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoungeExternalAppsView: BaseView {
  struct Metric {
    static let iconSize = 44
    static let sideMargin = 8
  }
  
  var clickSignal = PublishRelay<LoungeExternalSourceModel>()
  var disposeBag = DisposeBag()
  
  let titleLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 11)
    $0.textColor = CHColors.blueyGrey
    $0.text = CHAssets.localized("다른 방법으로 문의")
  }
  
  let containerView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 20
  }
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.titleLabel)
    self.addSubview(self.containerView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.titleLabel.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(10)
    }
    
    self.containerView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.top.equalTo(self.titleLabel.snp.bottom)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
  
  func configure(with models: [LoungeExternalSourceModel]) {
    for each in self.containerView.subviews {
      each.removeFromSuperview()
    }
    let marginSpaces = CGFloat(Metric.sideMargin * 2)
    let iconSpaces = CGFloat(models.count * Metric.iconSize)
    let spaceCount = CGFloat(models.count - 1)
    
    let spacing = spaceCount >= 1 ? (UIScreen.main.bounds.width - marginSpaces - iconSpaces)/spaceCount : 0.f
    if spacing > 0 {
      self.containerView.spacing = spacing
    }
    
    for model in models {
      let modelView = LoungeExternalAppView()
      modelView.layer.cornerRadius = 22
      modelView.snp.makeConstraints { (make) in
        make.height.equalTo(44)
        make.width.equalTo(44)
      }
      modelView.configure(with: model)
      modelView.signalForClick().subscribe(onNext: { [weak self] (_) in
        self?.clickSignal.accept(model)
      }).disposed(by: self.disposeBag)
      
      self.containerView.addArrangedSubview(modelView)
    }
  }
}

class LoungeExternalAppView: BaseView {
  let sourceImageView = UIImageView().then {
    $0.contentMode = .center
  }
  
  override func initialize() {
    super.initialize()
    
    self.clipsToBounds = true
    self.addSubview(self.sourceImageView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.sourceImageView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = self.frame.height / 2
  }
  
  func configure(with model: LoungeExternalSourceModel) {
    self.sourceImageView.image = model.type.image
  }
}
