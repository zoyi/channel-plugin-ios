//
//  LauncherView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 08/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift

final class LauncherView : BaseView {
  // MARK: Constant
  static let tagId = 0xDEADBEE
  
  struct Metric {
    static let badgeViewTopMargin = -4.f
    static let badgeViewRightMargin = -2.f
    static let badgeViewHeight = 20.f
  }
  
  // MARK: Properties 
  
  let badgeView = Badge().then {
    $0.minWidth = 10.f
    $0.layer.shadowColor = CHColors.dark20.cgColor
    $0.layer.shadowOpacity = 0.2
    $0.layer.shadowOffset = CGSize(width: 0, height: 1)
    $0.layer.shadowRadius = 2
  }
  let disposeBag = _RXSwift_DisposeBag()
  let buttonView = CHButtonFactory.launcher()
  
  //refactor this as general button
  let buttonLayerView = UIView().then {
    $0.backgroundColor = CHColors.dark50
    $0.layer.cornerRadius = 25.f
    $0.alpha = 0.5
  }

  let buttonGradientLayer = CAGradientLayer().then {
    $0.startPoint = CGPoint(x: 0.5, y: 0.0)
    $0.endPoint = CGPoint(x: 0.5, y: 1.0)
    $0.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    $0.locations = [0, 0.5, 1]
    $0.cornerRadius = 25
  }
  
  var layoutGuide: UILayoutGuide? = nil
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.buttonView)
    self.addSubview(self.buttonLayerView)
    self.addSubview(self.badgeView)
    self.buttonView.layer.insertSublayer(self.buttonGradientLayer, at: 0)
    
    self.buttonView.rx.isHighlighted
      .subscribe(onNext: { [weak self] (selected) in
        self?.buttonLayerView.alpha = selected ? 0.5 : 0
      }).disposed(by: self.disposeBag)
  }
  
  func configure(_ viewModel: LauncherViewModelType) {
    self.buttonGradientLayer.colors = viewModel.gradientColors
    
    self.buttonView.imageView?.contentMode = .scaleAspectFit
    self.buttonView.bringSubviewToFront(self.buttonView.imageView!)
    
    self.buttonView.setImage(viewModel.launchIcon!, for: .normal)
    self.buttonView.setImage(viewModel.launchIcon!, for: .highlighted)
  
    self.badgeView.configure(viewModel.badge)
    self.badgeView.isHidden = viewModel.badge == 0
  }

  override func setLayouts() {
    super.setLayouts()
    
    self.buttonView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.buttonLayerView.snp.makeConstraints { [weak self] (make) in
      make.edges.equalTo((self?.buttonView)!)
    }
    
    self.badgeView.snp.makeConstraints { (make) in
      make.height.equalTo(Metric.badgeViewHeight)
      make.top.equalToSuperview().inset(Metric.badgeViewTopMargin)
      make.trailing.equalToSuperview().inset(Metric.badgeViewRightMargin)
    }
  }
}
