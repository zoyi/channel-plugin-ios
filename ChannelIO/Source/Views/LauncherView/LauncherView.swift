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
  static let tagId = 0xDEADBEEF
  
  struct Metric {
    static var xMargin = 24.f
    static var yMargin = 24.f
    static var position = LauncherPosition.right
    
    static let viewSize = 54.f
    static let badgeViewTopMargin = -3.f
    static let badgeViewRightMargin = -3.f
    static let badgeViewHeight = 22.f
  }
  
  // MARK: Properties 
  
  let badgeView = Badge()
  let disposeBag = DisposeBag()
  let buttonView = UIButton().then {
    $0.layer.cornerRadius = Metric.viewSize/2.f
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.3
    $0.layer.shadowOffset = CGSize(width: 0, height: 3)
    $0.layer.shadowRadius = 5
    $0.layer.borderWidth = 1
  }
  
  var layoutGuide: UILayoutGuide? = nil
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.buttonView)
    self.addSubview(self.badgeView)
  }
  
  func configure(_ viewModel: LauncherViewModelType) {
    Metric.xMargin = viewModel.xMargin
    Metric.yMargin = viewModel.yMargin
    Metric.position = viewModel.position
    
    self.buttonView.backgroundColor = UIColor(viewModel.bgColor)
    self.buttonView.layer.borderColor = UIColor(viewModel.borderColor)?.cgColor
    
    let imageName = viewModel.iconColor == UIColor.white ? "balloonWhite" : "balloonBlack"
    self.buttonView.setImage(CHAssets.getImage(named: imageName), for: .normal)

    self.badgeView.configure(viewModel.badge)
    self.badgeView.isHidden = viewModel.badge == 0

    self.setNeedsLayout()
    self.layoutIfNeeded()
  }

  override func updateConstraints() {
    self.snp.remakeConstraints ({ [weak self] (make) in
      make.size.equalTo(CGSize(width:Metric.viewSize, height:Metric.viewSize))
      
      if Metric.position == LauncherPosition.right {
        make.right.equalToSuperview().inset(Metric.xMargin)
      } else if Metric.position == LauncherPosition.left {
        make.left.equalToSuperview().inset(Metric.xMargin)
      }
      
      if #available(iOS 11.0, *) {
        make.bottom.equalTo((self?.layoutGuide?.snp.bottom)!).offset(-Metric.yMargin)
      } else {
        make.bottom.equalToSuperview().inset(Metric.yMargin)
      }
    })
    
    self.buttonView.snp.remakeConstraints { (make) in
      make.edges.equalTo(0)
    }

    self.badgeView.snp.remakeConstraints { [weak self] (make) in
      make.height.equalTo(Metric.badgeViewHeight)
      make.top.equalToSuperview().inset(Metric.badgeViewTopMargin)
      make.centerX.equalTo((self?.snp.right)!).offset(-5)
    }
    
    super.updateConstraints()
  }
}
