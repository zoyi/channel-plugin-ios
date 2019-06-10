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
  var models: [LoungeExternalSourceModel] = []
  
  var refreshSignal = PublishRelay<Any?>()
  var clickSignal = PublishRelay<LoungeExternalSourceModel>()
  
  var disposeBag = DisposeBag()
  
  let titleLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 11)
    $0.textColor = CHColors.blueyGrey
    $0.text = CHAssets.localized("ch.integrations.title")
  }
  
  let containerView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = UIScreen.main.bounds.width == 320 ? 16 : 20
  }
  
  var refreshButton: UIButton?
  
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
  
  override func displayError() {
    let refreshButton = CHButtonFactory.errorRefresh()
    self.addSubview(refreshButton)
    refreshButton.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.top.equalTo(self.titleLabel.snp.bottom).offset(3)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalTo(44)
      make.width.equalTo(44)
    }
    
    _ = refreshButton.signalForClick().subscribe(onNext: { [weak self] (_) in
      self?.refreshSignal.accept(nil)
    })
    
    self.refreshButton?.removeFromSuperview()
    self.refreshButton = refreshButton
  }
  
  func reloadContent() {
    self.configure(with: self.models)
  }
  
  func configure(with models: [LoungeExternalSourceModel]) {
    for each in self.containerView.subviews {
      each.removeFromSuperview()
    }
    
    self.models = models
    self.titleLabel.text = CHAssets.localized("ch.integrations.title")
    
    for model in models {
      let modelView = LoungeExternalAppView()
      modelView.layer.cornerRadius = 22
      modelView.snp.makeConstraints { (make) in
        make.height.equalTo(44)
        make.width.equalTo(44)
      }
      modelView.configure(with: model)
      modelView.button.signalForClick().subscribe(onNext: { [weak self] (_) in
        self?.clickSignal.accept(model)
      }).disposed(by: self.disposeBag)
      
      self.containerView.addArrangedSubview(modelView)
    }
  }
}

class LoungeExternalAppView: BaseView {
  let button = UIButton(type: .system)
  
  override func initialize() {
    super.initialize()
    
    self.clipsToBounds = true
    self.backgroundColor = CHColors.dark10
    self.addSubview(self.button)
  }
  
  override func setLayouts() {
    super.setLayouts()

    self.button.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = self.frame.height / 2
  }
  
  func configure(with model: LoungeExternalSourceModel) {
    self.button.setImage(model.type.image?.withRenderingMode(.alwaysOriginal), for: .normal)
  }
}
