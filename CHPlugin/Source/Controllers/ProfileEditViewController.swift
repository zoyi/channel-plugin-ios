//
//  ProfileEditViewController.swift
//  CHPlugin
//
//  Created by Haeun Chung on 18/05/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import SVProgressHUD
import SnapKit
import RxSwift

enum EditFieldType {
  case name
  case phone
}

final class ProfileEditViewController: BaseViewController {
  
  let headerLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = CHColors.blueyGrey
  }
  
  var text = ""

  var type: EditFieldType = .name
  let disposeBag = DisposeBag()
  
  var fieldView: CHFieldProtocol!
  let footerLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.textColor = CHColors.blueyGrey
  }
  
  private var submitSubject = PublishSubject<String>()
  
  convenience init(type: EditFieldType, text: String = "") {
    self.init()
    
    self.type = type
    self.text = text
    
    switch type {
    case .name:
      let placeholder = CHAssets.localized("ch.settings.edit.name_placeholder")
      self.fieldView = CHTextField(text: self.text, placeholder: placeholder)
      self.title = CHAssets.localized("ch.settings.name_placeholder")
      self.headerLabel.text = CHAssets.localized("ch.settings.edit.name_label")
    case .phone:
      self.fieldView = CHPhoneField(text: self.text)
      self.title = CHAssets.localized("ch.settings.phone_number_placeholder")
      self.headerLabel.text = CHAssets.localized("ch.settings.edit.phone_number_label")
      self.footerLabel.text = CHAssets.localized("ch.settings.edit.phone_number_description")
    }
    
    self.fieldView.isValid()
      .subscribe(onNext: { [weak self] (valid) in
      self?.navigationItem.rightBarButtonItem?.isEnabled = valid
    }).disposed(by: self.disposeBag)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setNavigation()
    
    self.navigationController?.interactivePopGestureRecognizer?.delegate = nil;
    
    self.view.backgroundColor = CHColors.lightSnow
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
    let isWhite = mainStore.state.plugin.textColor == "white" ? true : false
    let backImage = CHAssets.getImage(named: "back")
    let navigationImage = isWhite ?
      backImage : backImage?.overlayWith(color: CHColors.black)
    
    self.navigationItem.leftBarButtonItem = NavigationItem(
      image:  navigationImage,
      style: .plain,
      actionHandler: { [weak self] in
        _ = self?.navigationController?
          .popViewController(animated: true)
      })
    
    self.navigationItem.rightBarButtonItem = NavigationItem(
      title: CHAssets.localized("ch.mobile_verification.confirm"),
      style: .plain,
      textColor: isWhite ? CHColors.white : CHColors.black,
      actionHandler: { [weak self] in
        if let text = self?.fieldView.getText() {
          self?.text = text
        }
        
        var guest = mainStore.state.guest
        if self?.type == .name {
          guest.name = self?.text ?? ""
        }
        if self?.type == .phone {
          guest.mobileNumber = self?.text == "" ? nil : self?.text
        }
        
        SVProgressHUD.show(
          withStatus: CHAssets.localized("ch.settings.changing_message")
        )
        
        guest.update()
          .subscribe(onNext: { (guest, error) in
            SVProgressHUD.dismiss()
            if error != nil  {
              return
            }
            
            mainStore.dispatch(UpdateGuest(payload: guest))
            _ = self?.navigationController?
              .popViewController(animated: true)
        }, onError: { (error) in
          //error
        }).disposed(by: (self?.disposeBag)!)
      })
    
    self.navigationItem.rightBarButtonItem?.isEnabled = false
  }
  
}

