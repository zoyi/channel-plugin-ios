//
//  LoungeView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

class LoungeView: BaseViewController, LoungeViewProtocol {
  var presenter: LoungePresenterProtocol?
  
  var scrollView = UIScrollView()
  let headerView = LoungeHeaderView()
  let mainView = LoungeMainView()
  let externalView = LoungeExternalAppsView()
  
  var disposeBag = DisposeBag()
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    SVProgressHUD.show()
    
    self.scrollView.delegate = self
    self.scrollView.alwaysBounceHorizontal = false
    self.scrollView.alwaysBounceVertical = true
    self.scrollView.showsVerticalScrollIndicator = false
    self.scrollView.showsHorizontalScrollIndicator = false
    self.scrollView.contentInset = UIEdgeInsets(top: 160, left: 0, bottom: 20, right: 0)
    self.scrollView.backgroundColor = .clear
    
    let gesture = UITapGestureRecognizer(target: self, action: #selector(tapCheck(_:)))
    self.scrollView.addGestureRecognizer(gesture)
    
    self.initViews()
    self.presenter?.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
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
    
    self.scrollView.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.leading.equalToSuperview().inset(8)
      make.trailing.equalToSuperview().inset(8)
      make.bottom.equalToSuperview()
    }
    
    self.mainView.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.width.equalTo(UIScreen.main.bounds.width - 16)
      make.height.equalTo(340)
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
  }
  
  @objc func tapCheck(_ gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: self.scrollView)
    
    //check if setting
//    if 0 {
//      self.presenter?.didClickOnSetting(from: self)
//    } else if 1 {
//      self.presenter?.didClickOnDismiss()
//    }
  }
}

extension LoungeView {
  func displayReady() {
    SVProgressHUD.dismiss()
  }
  
  func displayHeader(with model: LoungeHeaderViewModel) {
    self.headerView.configure(model: model)
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: 800)
  }
  
  func displayMainContent(with chats: [UserChatCellModel], welcomeModel: UserChatCellModel?) {
    self.mainView.configure(with: chats, welcomeModel: welcomeModel)
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: 800)
  }
  
  func displayExternalSources(with model: LoungeExternalSourceViewModel) {
    self.externalView.configure(with: model)
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: 800)
  }
}

extension LoungeView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //update button visibility
    //update header visibility
  }
}
