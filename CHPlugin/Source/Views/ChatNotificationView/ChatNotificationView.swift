//
//  ChatNotificationView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 09/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit

final class ChatNotificationView : BaseView {
  var clickSubject = PublishSubject<CHPush>()
  var topLayoutGuide: UILayoutSupport?
  
  // MARK: Constants
  struct Metric {
    static let sideMargin = 12.f
    static let topMargin = 10.f
    static let boxHeight = 68.f
    static let viewTopMargin = 8.f
    static let viewSideMargin = 10.f
    static let avatarSide = 38.f
    static let avatarTopMargin = 10.f
    static let avatarLeftMargin = 8.f
    static let nameTopMargin = 12.f
    static let nameLeftMargin = 8.f
    static let timestampTopMargin = 0.f
    static let closeSide = 40.f
    static let messageTopMargin = 3.f
    static let messageRightMargin = 29.f
    static let messageBotMargin = 12.f
    static let messageLeftMargin = 8.f
  }
  
  struct Font {
    static let messageLabel = UIFont.systemFont(ofSize: 14)
    static let nameLabel = UIFont.boldSystemFont(ofSize: 12)
  }
  
  struct Color {
    static let border = CHColors.white.cgColor
    static let messageLabel = CHColors.charcoalGrey
    static let nameLabel = CHColors.charcoalGrey
  }
  
  struct Constant {
    static let titleLabelNumberOfLines = 1
    static let messageLabelNumberOfLines = 1
    static let timestampLabelNumberOfLines = 1
    static let nameLabelNumberOfLines = 1
    static let cornerRadius = 8.f
    static let shadowColor = UIColor("#516378").cgColor
    static let shadowOffset = CGSize(width: 0.f, height: 5.f)
    static let shadowBlur = 15.f
    static let shadowOpacity = 0.4.f
  }

  // MARK: Properties
  let messageLabel = UILabel().then {
    $0.font = Font.messageLabel
    $0.textColor = Color.messageLabel
    $0.numberOfLines = Constant.messageLabelNumberOfLines
  }
  
  let nameLabel = UILabel().then {
    $0.font = Font.nameLabel
    $0.textColor = Color.nameLabel
    $0.numberOfLines = Constant.nameLabelNumberOfLines
  }
  
  let avatarView = AvatarView().then {
    $0.showBorder = false
  }
  
  let closeView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "cancelSmall")
    $0.contentMode = UIViewContentMode.center
    $0.layer.shadowOpacity = 0
  }
  
  override func initialize() {
    super.initialize()
    
    self.layer.borderColor = CHColors.darkTwo.cgColor
    self.layer.borderWidth = 1.f
    self.backgroundColor = CHColors.white
    
    self.layer.cornerRadius = Constant.cornerRadius
    self.layer.shadowColor = Constant.shadowColor
    self.layer.shadowOffset = Constant.shadowOffset
    self.layer.shadowRadius = Constant.shadowBlur
    self.layer.shadowOpacity = Float(Constant.shadowOpacity)
    
    self.addSubview(self.nameLabel)
    self.addSubview(self.messageLabel)
    self.addSubview(self.avatarView)
    self.addSubview(self.closeView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.nameLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(22)
      make.top.equalToSuperview().inset(13)
    }

    self.messageLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(22)
      make.bottom.equalToSuperview().inset(15)
    }
    
    self.avatarView.snp.makeConstraints { [weak self] (make) in
      make.centerY.equalToSuperview()
      make.size.equalTo(CGSize(width: Metric.avatarSide, height: Metric.avatarSide))
      make.leading.greaterThanOrEqualTo((self?.messageLabel.snp.trailing)!).offset(5)
      make.leading.greaterThanOrEqualTo((self?.nameLabel.snp.trailing)!).offset(5)
    }
    
    self.closeView.snp.makeConstraints { [weak self] (make) in
      make.size.equalTo(CGSize(width:Metric.closeSide, height:Metric.closeSide))
      make.centerY.equalToSuperview()
      make.leading.equalTo((self?.avatarView.snp.trailing)!)
      make.trailing.equalToSuperview()
    }
  }
  
  func configure(_ viewModel: ChatNotificationViewModelType) {
    self.messageLabel.text = viewModel.message
    self.nameLabel.text = viewModel.name
    self.avatarView.configure(viewModel.avatar)
  }
  
  override func updateConstraints() {
    self.snp.makeConstraints { [weak self] (make) in
      make.height.equalTo(Metric.boxHeight)
      if let top = self?.topLayoutGuide {
        make.top.equalTo(top.snp.bottom).offset(Metric.viewTopMargin)
      } else {
        make.top.equalToSuperview().inset(Metric.viewTopMargin)
      }
      
      make.leading.equalToSuperview().inset(Metric.viewSideMargin)
      make.trailing.equalToSuperview().inset(Metric.viewSideMargin)
    }
   
    super.updateConstraints()
  }
  
  // MARK: Signals 
  
  func onClick() -> Observable<CHPush> {
    return clickSubject
  }
}
