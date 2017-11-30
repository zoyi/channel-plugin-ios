//
//  ChatStatusExtensionView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 23/11/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class ChatStatusViewFactory {
  class func createFollowedExtensionView(
    fit width: CGFloat,
    userChat: CHUserChat?,
    channel: CHChannel,
    plugin: CHPlugin) -> UIView {
    
    let extensionViewHeight = ChatStatusFollowedView.viewHeight(manager: userChat?.lastTalkedManager)
    let statusView = ChatStatusFollowedView(frame: CGRect(x: 0, y: 0, width: width, height: extensionViewHeight))
    statusView.configure(lastTalkedPerson: userChat?.lastTalkedManager, channel: channel, plugin: plugin)
    return statusView
  }
  
  class func createDefaultExtensionView(
    fit width: CGFloat,
    userChat: CHUserChat?,
    channel: CHChannel,
    plugin: CHPlugin,
    managers: [CHManager]) -> UIView {
    
    let extensionViewHeight = ChatStatusDefaultView.viewHeight(fits: width, channel: channel, managers: managers)
    let statusView = ChatStatusDefaultView(frame: CGRect(x: 0, y:0, width: width, height: extensionViewHeight))
    statusView.configure(channel: mainStore.state.channel, plugin: mainStore.state.plugin)
    _ = statusView.signalForBusinessHoursClick().subscribe({ (_) in
      let channel = mainStore.state.channel
      let alertView = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
      alertView.title = ""
      alertView.message = channel.workingTimeString
      
      alertView.addAction(
        UIAlertAction(title: CHAssets.localized("ch.button_confirm"), style: .cancel) { _ in
          //nothing
        }
      )
      let topController = CHUtils.getTopController()
      topController?.present(alertView, animated: true, completion: nil)
    })
    return statusView
  }
}

class ChatStatusDefaultView : BaseView {
  let disposeBag = DisposeBag()
  let businessSubject = PublishSubject<Any?>()
  
  let statusLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 14)
  }
  
  let statusImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "offhoursW")
    $0.contentMode = .center
  }
  
  let statusDescLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.numberOfLines = 0
  }
  
  let multiAvatarView = CHMultiAvatarView(avatarSize: 46, coverMargin: 6).then {
    $0.showBorder = true
  }
  
  let divider = UIView().then {
    $0.isHidden = false
    $0.alpha = 0.3
    $0.backgroundColor = UIColor.white
  }
  
  let businessHoursView = UIView().then {
    $0.isHidden = false
  }
  let businessHoursLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.numberOfLines = 0
    $0.textAlignment = .center
  }
  
  var avatarWidthContraint: Constraint? = nil
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.statusLabel)
    self.addSubview(self.statusImageView)
    self.addSubview(self.statusDescLabel)
    self.addSubview(self.multiAvatarView)
    self.addSubview(self.divider)
    self.businessHoursView.addSubview(self.businessHoursLabel)
    self.addSubview(self.businessHoursView)
    
    self.businessHoursView.signalForClick()
      .subscribe { [weak self] (_) in
        self?.businessSubject.onNext(nil)
      }.disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.statusLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(18)
      make.top.equalToSuperview().inset(10)
    }
    
    self.statusImageView.snp.makeConstraints { [weak self] (make) in
      make.centerY.equalTo((self?.statusLabel.snp.centerY)!)
      make.leading.equalTo((self?.statusLabel.snp.trailing)!)
      //make.trailing.lessThanOrEqualTo((self?.multiAvatarView.snp.leading)!).offset(10)
      make.height.equalTo(22)
      make.width.equalTo(22)
    }
    
    self.statusDescLabel.snp.makeConstraints { [weak self] (make) in
      make.leading.equalToSuperview().inset(18)
      make.top.equalTo((self?.statusLabel.snp.bottom)!).offset(4)
      //make.trailing.equalTo((self?.multiAvatarView.snp.leading)!).offset(-10)
    }
    
    self.multiAvatarView.snp.makeConstraints { [weak self] (make) in
      make.trailing.equalToSuperview().inset(20)
      make.top.equalToSuperview().inset(10)
      make.leading.equalTo((self?.statusDescLabel.snp.trailing)!).offset(10)
      //make.height.equalTo(46)
      //self?.avatarWidthContraint = make.width.equalTo(46).constraint
    }
    
    self.divider.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.statusDescLabel.snp.bottom)!).offset(15)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.height.equalTo(0.5)
    }
    
    self.businessHoursView.snp.makeConstraints { [weak self] (make) in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.top.equalTo((self?.divider.snp.bottom)!)
      make.bottom.equalToSuperview()
    }
    
    self.businessHoursLabel.snp.makeConstraints { (make) in
        make.leading.equalToSuperview().inset(18)
        make.trailing.equalToSuperview().inset(18)
        make.top.equalToSuperview().inset(15)
        make.bottom.equalToSuperview().inset(15)
    }
  }
  
  func signalForBusinessHoursClick() -> Observable<Any?> {
    return self.businessSubject
  }
  
  func configure(channel: CHChannel, plugin: CHPlugin) {
    self.backgroundColor = UIColor(plugin.color)

    if !channel.working {
      self.statusLabel.text = CHAssets.localized("ch.chat.expect_response_delay.out_of_working")
      self.statusDescLabel.text = CHAssets.localized("ch.chat.expect_response_delay.out_of_working.description")
      self.statusImageView.image = plugin.textColor == "white" ?
        CHAssets.getImage(named: "offhoursW") :
        CHAssets.getImage(named: "offhoursB")
    } else {
      self.statusLabel.text = CHAssets.localized("ch.chat.expect_response_delay.\(channel.expectedResponseDelay)")
      self.statusDescLabel.text = CHAssets.localized("ch.chat.expect_response_delay.\(channel.expectedResponseDelay).description")
      self.statusImageView.image = plugin.textColor == "white" ?
        CHAssets.getImage(named: "\(channel.expectedResponseDelay)W") :
        CHAssets.getImage(named: "\(channel.expectedResponseDelay)B")
    }
    
    let attributedString = NSMutableAttributedString(string: self.statusDescLabel.text!)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.minimumLineHeight = 18.f
    attributedString.addAttribute(
      NSAttributedStringKey.paragraphStyle,
      value:paragraphStyle,
      range:NSMakeRange(0, attributedString.length))
    self.statusDescLabel.attributedText = attributedString;
    
    self.statusLabel.textColor = plugin.textUIColor
    self.statusDescLabel.textColor = plugin.textUIColor
    
    let managers = mainStore.state.managersState.managerDictionary.map { (key, value) -> CHManager in
      return value
    }
    self.multiAvatarView.configure(persons: managers)
    
    if let workingTime = channel.workingTime, workingTime.count != 0 {
      self.divider.isHidden = false
      self.businessHoursLabel.text = CHAssets.localized("ch.chat.expect_response_delay.out_of_working.detail")
      self.businessHoursLabel.textColor = plugin.textUIColor
    } else {
      self.divider.isHidden = true
      self.businessHoursLabel.text = ""
    }
  }
  
  static func viewHeight(fits width: CGFloat, channel: CHChannel, managers: [CHManager]) -> CGFloat {
    var height: CGFloat = 0
    var avatarWidth:CGFloat = 20 //default margin
    if managers.count == 0 {
      avatarWidth = 20
    } else if managers.count == 1 {
      avatarWidth += 64
    } else if managers.count == 2 {
      avatarWidth += 102
    } else {
      avatarWidth += 140
    }
    //3 - 140, 2 - 102, 1 - 64
    
    height += 10 //top margin
    if !channel.working {
      height += CHAssets.localized("ch.chat.expect_response_delay.out_of_working")
        .height(fits: width - avatarWidth, font: UIFont.boldSystemFont(ofSize: 14))
      height += CHAssets.localized("ch.chat.expect_response_delay.out_of_working.description")
        .height(fits: width - avatarWidth, font: UIFont.systemFont(ofSize: 13))
    } else {
      height += CHAssets.localized("ch.chat.expect_response_delay.\(channel.expectedResponseDelay)")
        .height(fits: width - avatarWidth, font: UIFont.boldSystemFont(ofSize: 14))
      height += CHAssets.localized("ch.chat.expect_response_delay.\(channel.expectedResponseDelay).description")
        .height(fits: width - avatarWidth, font: UIFont.systemFont(ofSize: 13))
    }
    height += 4 //between margin
    height += 15 //bottom margin
    
    //if business hour set ..
    if let workingTime = channel.workingTime, workingTime.count != 0 {
      height += 15 //top
      height += CHAssets.localized("ch.chat.expect_response_delay.out_of_working.detail")
        .height(fits: width - 20, font: UIFont.boldSystemFont(ofSize: 13))
      height += 15 //bottom
      height += 5
    }

    return height
  }
}
