//
//  LauncherView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 08/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import ReSwift
import SnapKit

final class LauncherView : BaseView {
  // MARK: Constant
  static let tagId = 0xDEADBEE
  
  struct Metric {
    static let badgeViewTopMargin = -3.f
    static let badgeViewRightMargin = -3.f
    static let badgeViewHeight = 22.f
  }
  
  // MARK: Properties 
  
  let badgeView = Badge()
  let disposeBag = DisposeBag()
  let buttonView = CHButton.launcher()
  
  //refactor this as general button
  let buttonLayerView = UIView().then {
    $0.backgroundColor = CHColors.dark50
    $0.layer.cornerRadius = 27.f
    $0.alpha = 0.5
  }

  var layoutGuide: UILayoutGuide? = nil
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.buttonView)
    self.addSubview(self.buttonLayerView)
    self.addSubview(self.badgeView)
    
    self.buttonView.rx.isHighlighted
      .subscribe(onNext: { [weak self] (selected) in
        self?.buttonLayerView.alpha = selected ? 0.5 : 0
      }).disposed(by: self.disposeBag)
  }
  
  func configure(_ viewModel: LauncherViewModelType) {
    self.buttonView.backgroundColor = UIColor(viewModel.bgColor)
    self.buttonView.layer.borderColor = UIColor(viewModel.borderColor)?.cgColor
    
    let imageName = viewModel.iconColor == UIColor.white ? "balloonWhite" : "balloonBlack"
    self.buttonView.setImage(CHAssets.getImage(named: imageName), for: .normal)
    self.buttonView.setImage(CHAssets.getImage(named: imageName), for: .highlighted)
    
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
    
    self.badgeView.snp.makeConstraints { [weak self] (make) in
      make.height.equalTo(Metric.badgeViewHeight)
      make.top.equalToSuperview().inset(Metric.badgeViewTopMargin)
      make.centerX.equalTo((self?.snp.right)!).offset(-5)
    }
  }
}
