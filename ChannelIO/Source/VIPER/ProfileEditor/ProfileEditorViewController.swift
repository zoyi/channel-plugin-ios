//
//  ProfileEditorViewController.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import SVProgressHUD
import SnapKit

class ProfileEditorViewController: BaseViewController {
  var profileItem: GuestProfileItemModel?
  
  let headerLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = CHColors.blueyGrey
  }
  
  var text = ""
  var guest: CHGuest?

  var schema: CHProfileSchema?
  
  var entityType: EntityType = .none
  
  var type: EditFieldType = .name
  var fieldView: CHFieldDelegate!
  let footerLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.textColor = CHColors.blueyGrey
    $0.numberOfLines = 0
  }
  
  private var submitSubject = PublishSubject<String>()
  var disposeBag = DisposeBag()
  
  convenience init(type: EditFieldType, guest: CHGuest, schema: CHProfileSchema? = nil) {
    self.init()
    
    self.type = type
    self.guest = guest
    self.entityType = .guest
    self.title = CHAssets.localized("정보수정")
    
    switch type {
    case .name:
      self.text = guest.name
      self.fieldView = CHEditTextField(
        text: self.text,
        placeholder: CHAssets.localized("없음"))
      self.headerLabel.text = CHAssets.localized("userchat.detail.edit.name_label")
    case .phone:
      self.text = guest.mobileNumber ?? ""
      self.fieldView = CHPhoneField(text: self.text)
      self.headerLabel.text = CHAssets.localized("userchat.detail.edit.phone_label")
      self.footerLabel.text = CHAssets.localized("userchat.detail.edit.phone_description")
    case .text:
      let key = schema?.key ?? ""
      self.text = guest.profile?[key] as? String ?? ""
      self.fieldView = CHEditTextField(
        text: self.text,
        type: .text,
        placeholder: CHAssets.localized("userchat.detail.edit_profile.placeholder"))
      self.headerLabel.text = schema?.nameI18n?.getMessage() ?? ""
    case .number:
      let key = schema?.key ?? ""
      if let value = guest.profile?[key] {
        self.text =  "\(value)"
      }
      self.fieldView = CHEditTextField(
        text: self.text,
        type: .number,
        placeholder: CHAssets.localized("userchat.detail.edit_profile.placeholder"))
      self.headerLabel.text = schema?.nameI18n?.getMessage() ?? ""
    }
    
    self.schema = schema
    
    self.fieldView.isValid()
      .subscribe(onNext: { [weak self] (valid) in
        self?.navigationItem.rightBarButtonItem?.isEnabled = valid
      }).disposed(by: self.disposeBag)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setNavigation()
    
    self.view.backgroundColor = CHColors.lightGray
    self.view.addSubview(self.headerLabel)
    self.view.addSubview(self.fieldView as! UIView)
    self.view.addSubview(self.footerLabel)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.headerLabel.snp.remakeConstraints { (make) in
      make.leading.equalToSuperview().inset(16)
      make.top.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(16)
    }
    
    let fieldView = self.fieldView as! UIView
    fieldView.snp.remakeConstraints { [weak self] (make) in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.top.equalTo((self?.headerLabel.snp.bottom)!).offset(6)
      make.height.equalTo(52)
    }
    
    self.footerLabel.snp.remakeConstraints { (make) in
      make.top.equalTo(fieldView.snp.bottom).offset(6)
      make.leading.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(16)
    }
  }
  
  func setNavigation() {
//    self.navigationItem.rightMargin = 16
//    self.navigationItem.rightBarButtonItem = NavigationItem(
//      title: "edit_manager.save_button".localized,
//      style: .plain,
//      textColor: self.channel?.textUIColor ?? UIColor.black,
//      actionHandler: { [weak self] _ in
//        if let text = self?.fieldView.getText() {
//          self?.text = text
//        }
//
//        if self?.entityType == .manager {
//          self?.updateManagerInfo()
//        } else if self?.entityType == .guest {
//          self?.updateGuestInfo()
//        }
//    })
  }
  
  func updateGuestInfo() {
    SVProgressHUD.show(withStatus: CHAssets.localized("edit_manager.changing_message"))
    
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    
    let key : String = self.type == .name ? "name" : self.schema?.key ?? ""
    let value : Any? = self.type == .number ?
      numberFormatter.number(from: self.text) :
      (self.text == "" ? nil : self.text)
    
    self.guest?.updateProfile(key: key, value: value)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (guest, error) in
        SVProgressHUD.dismiss()
        
        mainStore.dispatch(UpdateGuest(payload: guest))
        if error == nil {
          _ = self?.navigationController?.popViewController(animated: true)
        }
        }, onError: { (error) in
          //error
      }).disposed(by: self.disposeBag)
  }
}
