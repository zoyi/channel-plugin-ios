
//  ProfileEditorViewController.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift

class ProfileEditorViewController: BaseViewController {
  private enum Metrics {
    static let defaultHeight = 52.f
    static let booleanHeight = 156.f
  }
  
  private let footerLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.textColor = .grey500
    $0.numberOfLines = 0
  }
  
  private var text = ""
  private var user: CHUser?
  private var schema: CHProfileSchema?
  
  private var entityType: EntityType = .none
  private var type: EditFieldType = .name
  private var fieldView: CHFieldDelegate!
  
  private var isBoolean: Bool = false
  
  private var submitSubject = _RXSwift_PublishSubject<String>()
  private var disposeBag = _RXSwift_DisposeBag()
  
  convenience init(type: EditFieldType, user: CHUser, schema: CHProfileSchema? = nil) {
    self.init()
    
    self.type = type
    self.user = user
    self.entityType = .user
    self.isBoolean = false
    
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
    case .date:
      let key = schema?.key ?? ""
      var date: Date? = nil
      if let value = user.profile?[key] as? Double {
        date = Date.init(timeIntervalSince1970: value / 1000)
      }
      self.text = date?.fullDateString() ?? ""
      self.fieldView = CHDateField(date: date)
    case .boolean:
      self.isBoolean = true
      let key = schema?.key ?? ""
      if let value = user.profile?[key] {
        self.text =  "\(value)"
      }
      self.fieldView = CHBooleanField(
        bool: self.text == "true"
          ? true : self.text.isEmpty
          ? nil : false
      )
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
      make.height.equalTo(self.isBoolean ? Metrics.booleanHeight : Metrics.defaultHeight)
    }
    
    self.footerLabel.snp.remakeConstraints { (make) in
      make.top.equalTo(fieldView.snp.bottom).offset(6)
      make.leading.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(16)
    }
  }
  
  func setNavigation() {
    let titleView = SimpleNavigationTitleView()
    titleView.configure(
      with: self.schema?.nameI18n,
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
    let hud = _ChannelIO_JGProgressHUD(style: .JGProgressHUDStyleDark)
    hud.textLabel.text = CHAssets.localized("ch.loader.updating")
    hud.show(in: self.view)
    
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    
    let key : String = self.schema?.key ?? ""
    let value : Any?
    
    switch self.type {
    case .number, .date:
      value = numberFormatter.number(from: self.text)
    default:
      value = self.text == "" ? nil : self.text
    }
      
    self.user?.updateProfile(key: key, value: value)
      .debounce(.seconds(1), scheduler: _RXSwift_MainScheduler.instance)
      .observeOn(_RXSwift_MainScheduler.instance)
      .subscribe(onNext: { [weak self] (user, error) in
        defer { hud.dismiss() }
        ChannelIO.delegate?.onChangeProfile?(key: key, value: user?.profile?[key])
        ChannelIO.delegate?.onProfileChanged?(key: key, value: user?.profile?[key])
        mainStore.dispatch(UpdateUser(payload: user))
        if let error = error {
          CHNotification.shared.display(
            message: error.errorDescription ?? error.localizedDescription,
            config: CHNotificationConfiguration.warningServerErrorConfig
          )
        } else {
          _ = self?.navigationController?.popViewController(animated: true)
        }
      }).disposed(by: self.disposeBag)
  }
}
