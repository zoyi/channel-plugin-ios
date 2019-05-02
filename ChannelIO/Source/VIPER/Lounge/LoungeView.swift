//
//  LoungeView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import SVProgressHUD

class LoungeView: BaseViewController, LoungeViewProtocol {
  struct Metric {
    static let scrollInsetTop = 160.f
    static let scrollInsetBottom = 20.f
  }
  
  var presenter: LoungePresenterProtocol?
  
  var scrollView = UIScrollView()
  let headerView = LoungeHeaderView()
  let mainView = LoungeMainView()
  let externalView = LoungeExternalAppsView()

  var dismissButton = CHButton.dismiss().then {
    $0.alpha = 1
  }
  
  var disposeBag = DisposeBag()
  var mainHeightConstraint: Constraint?
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return self.navigationController?.preferredStatusBarStyle ?? .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    SVProgressHUD.show()
    
    self.scrollView.delegate = self
    self.scrollView.alwaysBounceHorizontal = false
    self.scrollView.alwaysBounceVertical = true
    self.scrollView.showsVerticalScrollIndicator = false
    self.scrollView.showsHorizontalScrollIndicator = false
    self.scrollView.contentInset = UIEdgeInsets(
      top: Metric.scrollInsetTop,
      left: 0,
      bottom: Metric.scrollInsetBottom,
      right: 0)
    self.scrollView.backgroundColor = .clear
    
    let gesture = UITapGestureRecognizer(target: self, action: #selector(tapCheck(_:)))
    self.scrollView.addGestureRecognizer(gesture)
    
    self.initViews()
    self.presenter?.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //navigation bar is weird..
    self.navigationController?.isNavigationBarHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.headerView.snp.makeConstraints { (make) in
      make.height.equalTo(270)
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    
    self.dismissButton.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      if #available(iOS 11.0, *) {
        make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(6)
      } else {
        make.top.equalToSuperview().inset(6)
      }
      make.height.equalTo(30)
      make.width.equalTo(30)
      make.trailing.equalToSuperview().inset(12)
    }
    
    self.scrollView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      if #available(iOS 11.0, *) {
        make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
      } else {
        make.top.equalToSuperview()
      }
      make.leading.equalToSuperview().inset(8)
      make.trailing.equalToSuperview().inset(8)
      make.bottom.equalToSuperview()
    }
    
    self.mainView.snp.makeConstraints { [weak self] (make) in
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.width.equalTo(UIScreen.main.bounds.width - 16)
      self?.mainHeightConstraint = make.height.equalTo(340).constraint
    }
    
    self.externalView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.height.equalTo(80)
      make.top.equalTo(self.mainView.snp.bottom).offset(8)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
  
  func initViews() {
    self.view.addSubview(self.headerView)
    self.headerView.settingSignal
      .subscribe(onNext: { [weak self] (_) in
        self?.presenter?.didClickOnSetting(from: self)
      }).disposed(by: self.disposeBag)
    self.headerView.dismissSignal
      .subscribe(onNext: { [weak self] (_) in
        self?.presenter?.didClickOnDismiss()
      }).disposed(by: self.disposeBag)
    
    self.view.addSubview(self.scrollView)
    self.scrollView.addSubview(self.mainView)
    self.mainView.signalForChat()
      .subscribe(onNext: { [weak self] (chat) in
        self?.presenter?.didClickOnChat(with: chat.chatId, from: self)
      }).disposed(by: self.disposeBag)
    self.mainView.signalForNew()
      .subscribe(onNext: { [weak self] (_) in
        self?.presenter?.didClickOnNewChat(from: self)
      }).disposed(by: self.disposeBag)
    self.mainView.signalForMore()
      .subscribe(onNext: { [weak self] (_) in
        self?.presenter?.didClickOnSeeMoreChat(from: self)
      }).disposed(by: self.disposeBag)
    
    self.scrollView.addSubview(self.externalView)
    self.externalView.clickSignal
      .subscribe(onNext: { [weak self] (source) in
        self?.presenter?.didClickOnExternalSource(with: source, from: self)
      }).disposed(by: self.disposeBag)
    
    self.view.addSubview(self.dismissButton)
  }
  
  @objc func tapCheck(_ gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: self.view)
    
    if self.headerView.dismissButton.frame.contains(location) {
      self.presenter?.didClickOnDismiss()
    } else if self.headerView.settingButton.frame.contains(location) {
      self.presenter?.didClickOnSetting(from: self)
    }
  }
}

extension LoungeView {
  func displayReady() {
    SVProgressHUD.dismiss()
  }
  
  func displayHeader(with model: LoungeHeaderViewModel) {
    self.headerView.configure(model: model)
  }
  
  func displayMainContent(with chats: [UserChatCellModel], welcomeModel: UserChatCellModel?) {
    self.mainView.configure(with: chats, welcomeModel: welcomeModel)
    self.mainHeightConstraint?.update(offset: self.mainView.viewHeight)
  }
  
  func displayExternalSources(with model: LoungeExternalSourceViewModel) {
    self.externalView.configure(with: model)
  }
}

extension LoungeView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let progress = (Metric.scrollInsetTop + scrollView.contentOffset.y)/Metric.scrollInsetTop
    self.dismissButton.alpha = progress
    self.headerView.change(with: 1 - progress)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    var height: CGFloat = 0
    height += self.mainView.frame.size.height
    height += self.externalView.frame.size.height
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: height)
  }
}
