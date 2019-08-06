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
  private struct Metrics {
    static let iconSize = 44
    static let sideMargin = 8
    static let spacing = UIScreen.main.bounds.width == 320 ? 16.f : 20.f
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = Metrics.spacing
  }
  
  private var refreshButton: UIButton?
  
  private var models: [LoungeExternalSourceModel] = []
  private var disposeBag = DisposeBag()
  
  var refreshSignal = PublishRelay<Any?>()
  var clickSignal = PublishRelay<LoungeExternalSourceModel>()
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.containerView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.containerView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
  
  override func displayError() {
    let refreshButton = CHButtonFactory.errorRefresh()
    self.addSubview(refreshButton)
    refreshButton.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
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
    
    for model in models {
      let modelView = LoungeExternalAppView()
      modelView.layer.cornerRadius = 22
      modelView.snp.makeConstraints { (make) in
        make.height.equalTo(Metrics.iconSize)
        make.width.equalTo(Metrics.iconSize)
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
