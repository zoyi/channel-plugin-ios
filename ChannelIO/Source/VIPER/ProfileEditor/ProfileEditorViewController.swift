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
  let footerLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.textColor = CHColors.blueyGrey
    $0.numberOfLines = 0
  }
  
  var text = ""
  var user: CHUser?
  var schema: CHProfileSchema?
  
  var entityType: EntityType = .none
  var type: EditFieldType = .name
  var fieldView: CHFieldDelegate!
  
  private var submitSubject = PublishSubject<String>()
  var disposeBag = DisposeBag()
  
  convenience init(type: EditFieldType, user: CHUser, schema: CHProfileSchema? = nil) {
    self.init()
    
    self.type = type
    self.user = user
    self.entityType = .user

    switch type {
    case .name:
      self.text = user.name
      self.fieldView = CHEditTextField(
        text: self.text,
        placeholder: CHAssets.localized("ch.settings.edit.name_placeholder"))
    case .phone:
      self.text = user.mobileNumber ?? ""
      self.fieldView = CHPhoneField(text: self.text)
      self.footerLabel.text = CHAssets.localized("ch.settings.edit.phone_number_description")
    case .text:
      let key = schema?.key ?? ""
      self.text = user.profile?[key] as? String ?? ""
      self.fieldView = CHEditTextField(
        text: self.text,
        type: .text,
        placeholder: CHAssets.localized("ch.profile_form.placeholder"))
    case .number:
      let key = schema?.key ?? ""
      if let value = user.profile?[key] {
        self.text =  "\(value)"
      }
      self.fieldView = CHEditTextField(
        text: self.text,
        type: .number,
        placeholder: CHAssets.localized("ch.profile_form.placeholder"))
    }
    
    self.schema = schema
    
    self.fieldView.isValid()
      .subscribe(onNext: { [weak self] (valid) in
        self?.navigationItem.rightBarButtonItem?.isEnabled = valid
      }).disposed(by: self.disposeBag)
    
    self.fieldView.hasChanged()
      .subscribe(onNext: { [weak self] (value) in
        self?.text = value
      }).disposed(by: self.disposeBag)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setNavigation()
    
    self.view.backgroundColor = .white
    self.view.addSubview(self.fieldView as! UIView)
    self.view.addSubview(self.footerLabel)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.removeShadow()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.dropShadow()
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    let fieldView = self.fieldView as! UIView
    fieldView.snp.remakeConstraints { (make) in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.top.equalToSuperview().inset(38)
      make.height.equalTo(52)
    }
    
    self.footerLabel.snp.remakeConstraints { (make) in
      make.top.equalTo(fieldView.snp.bottom).offset(6)
      make.leading.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(16)
    }
  }
  
  func setNavigation() {
    let title = self.schema?.nameI18n?.getMessage() ?? ""
    let titleView = SimpleNavigationTitleView()
    titleView.configure(
      with: title,
      textColor: mainStore.state.plugin.textUIColor
    )
    self.navigationItem.titleView = titleView
    
    self.navigationItem.rightBarButtonItem = NavigationItem(
      title: CHAssets.localized("ch.settings.save"),
      style: .plain,
      textColor: mainStore.state.plugin.textUIColor,
      actionHandler: { [weak self] in
        if let text = self?.fieldView.getText() {
          self?.text = text
        }
        self?.updateUserInfo()
      })
    
    let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    spacer.width = -8
    
    let backButton = NavigationItem(
      image:  CHAssets.getImage(named: "back"),
      tintColor: mainStore.state.plugin.textUIColor,
      style: .plain,
      actionHandler: { [weak self] in
        _ = self?.navigationController?.popViewController(animated: true)
    })
    
    if #available(iOS 11, *) {
      self.navigationItem.leftBarButtonItems = [backButton]
    } else {
      self.navigationItem.leftBarButtonItems = [spacer, backButton]
    }
  }
  
  func updateUserInfo() {
    SVProgressHUD.show(withStatus: CHAssets.localized("ch.loader.updating"))
    
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    
    let key : String = self.schema?.key ?? ""
    let value : Any? = self.type == .number ?
      numberFormatter.number(from: self.text) :
      (self.text == "" ? nil : self.text)
    
    self.user?.updateProfile(key: key, value: value)
      .debounce(.seconds(1), scheduler: MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (user, error) in
        defer { SVProgressHUD.dismiss() }
        ChannelIO.delegate?.onChangeProfile?(key: key, value: user?.profile?[key])
        mainStore.dispatch(UpdateUser(payload: user))
        if error == nil {
          _ = self?.navigationController?.popViewController(animated: true)
        }
      }, onError: { (error) in
          //error
      }).disposed(by: self.disposeBag)
  }
}
