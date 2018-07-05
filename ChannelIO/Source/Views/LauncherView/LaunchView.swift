//
//  LaunchView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 08/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import ReSwift
import SnapKit

final class LaunchView : BaseView {
  // MARK: Constant
  static let tagId = 0xDEADBEF
  
  struct Metric {
    static var xMargin = 24.f
    static var yMargin = 24.f
    
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
    //$0.setImage(Assets.getImage(named: "balloon")?.withRenderingMode(.alwaysTemplate), for: .normal)
  }
  
  var layoutGuide: UILayoutGuide? = nil
  
  override func initialize() {
    super.initialize()
    self.tag = LaunchView.tagId
    self.addSubview(self.buttonView)
    self.addSubview(self.badgeView)
    
    NotificationCenter.default.rx
      .notification(Notification.Name.Channel.updateBadge, object: nil)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (notification) in
        if let model = notification.userInfo?["model"] as? LaunchViewModel {
          self?.configure(model)
        }
      }).disposed(by: self.disposeBag)
    
    NotificationCenter.default.rx
      .notification(Notification.Name.Channel.dismissLaunchers, object: nil)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (notification) in
        if let animated = notification.userInfo?["animated"] as? Bool {
          self?.remove(animated: aniamted)
        } else {
          self?.removeFromSuperview()
        }
      }).disposed(by: self.disposeBag)
  }
  
  func configure(_ viewModel: LaunchViewModelType) {
    Metric.xMargin = viewModel.xMargin
    Metric.yMargin = viewModel.yMargin

    self.buttonView.backgroundColor = UIColor(viewModel.bgColor)
    self.buttonView.layer.borderColor = UIColor(viewModel.borderColor)?.cgColor
    if viewModel.iconColor == UIColor.white {
      self.buttonView.setImage(CHAssets.getImage(named: "balloonWhite"), for: .normal)
    } else {
      self.buttonView.setImage(CHAssets.getImage(named: "balloonBlack"), for: .normal)
    }
    
    //self.buttonView.imageView?.tintColor = viewModel.iconColor
    self.badgeView.configure(viewModel.badge)
    self.badgeView.isHidden = viewModel.badge == 0

    self.setNeedsLayout()
    self.layoutIfNeeded()
  }

  override func updateConstraints() {
    self.snp.remakeConstraints ({ [weak self] (make) in
      make.size.equalTo(CGSize(width:Metric.viewSize, height:Metric.viewSize))
      make.right.equalToSuperview().inset(Metric.xMargin)
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
      //make.right.equalToSuperview().inset(Metric.badgeViewRightMargin)
    }
    
    super.updateConstraints()
  }
}
