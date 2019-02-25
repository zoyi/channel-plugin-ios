//
//  ChannelIO+Helper.swift
//  CHPlugin
//
//  Created by Haeun Chung on 29/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import RxSwift
import RxSwiftExt
import CRToast
import SVProgressHUD

extension ChannelIO {
  
  internal class func reset() {
    PushBotManager.reset()
    ChannelIO.launcherView?.hide(animated: false)
    ChannelIO.close(animated: false)
    ChannelIO.hideNotification()
    mainStore.dispatch(CheckOutSuccess())
    WsService.shared.disconnect()
    disposeBag = DisposeBag()
  }
  
  internal class func prepare() {
    if let subscriber = ChannelIO.subscriber {
      mainStore.unsubscribe(subscriber)
    }
    
    let toastOptions:[AnyHashable: Any] = [
      kCRToastNotificationPresentationTypeKey: CRToastPresentationType.cover.rawValue,
      kCRToastNotificationTypeKey: CRToastType.navigationBar.rawValue,
      kCRToastAnimationInDirectionKey: CRToastAnimationDirection.top.rawValue,
      kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.top.rawValue,
      kCRToastBackgroundColorKey: CHColors.yellow,
      kCRToastTextColorKey: UIColor.white,
      kCRToastFontKey: UIFont.boldSystemFont(ofSize: 13)
    ]
    
    ChannelIO.reset()
  
    let subscriber = CHPluginSubscriber()
    mainStore.subscribe(subscriber)
    ChannelIO.subscriber = subscriber
    
    CRToastManager.setDefaultOptions(toastOptions)
    SVProgressHUD.setDefaultStyle(.dark)
  }
  
  internal class func track(eventName: String, eventProperty: [String: Any]?, sysProperty: [String: Any]?) {
    if eventName.utf16.count > 30 || eventName == "" {
      return
    }
    
    CHEvent.send(
      pluginId: mainStore.state.plugin.id,
      name: eventName,
      property: eventProperty,
      sysProperty: sysProperty)
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while sending the event \(eventName). Attempting to send again")
        return true
      })
      .subscribe(onNext: { (event, nudges) in
        dlog("\(eventName) event sent successfully")
        PushBotManager.process(with: nudges, property: eventProperty ?? [:])
      }, onError: { (error) in
        dlog("\(eventName) event failed")
      }).disposed(by: disposeBag)
  }

  internal class func checkInChannel(profile: Profile? = nil) -> Observable<Any?> {
    return Observable.create { subscriber in
      guard let settings = ChannelIO.settings else {
        subscriber.onError(CHErrorPool.unknownError)
        return Disposables.create()
      }
      
      guard settings.pluginKey != "" else {
        subscriber.onError(CHErrorPool.pluginKeyError)
        return Disposables.create()
      }
      
      if let userId = settings.userId, userId != "" {
        PrefStore.setCurrentUserId(userId: userId)
      } else {
        PrefStore.clearCurrentUserId()
      }

      let params = BootParamBuilder()
        .with(userId: settings.userId)
        .with(profile: profile)
        .with(sysProfile: nil, includeDefault: true)
        .build()
      
      //refactor into one class
      AppManager
        .boot(pluginKey: settings.pluginKey, params: params)
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          dlog("Error while booting channelSDK. Attempting to boot again")
          return true
        })
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (data) in
          var data = data
          guard let channel = data["channel"] as? CHChannel else {
            subscriber.onError(CHErrorPool.unknownError)
            return
          }

          if channel.notAllowToUseSDK && !channel.trial {
            subscriber.onError(CHErrorPool.serviceBlockedError)
            return
          }
          
          data["settings"] = settings
          mainStore.dispatch(CheckInSuccess(payload: data))
          
          WsService.shared.connect()
          WsService.shared.ready().subscribe(onNext: { _ in
            subscriber.onNext(data)
            subscriber.onCompleted()
          }).disposed(by: disposeBag)
          
        }, onError: { error in
          subscriber.onError(error)
        }, onCompleted: {
          dlog("Check in complete")
        }).disposed(by: disposeBag)
      
      return Disposables.create()
    }
  }
  
  internal class func showUserChat(userChatId: String?, animated: Bool = true) {
    guard let topController = CHUtils.getTopController() else {
      return
    }
    
    dispatch {
      ChannelIO.launcherView?.isHidden = true
      mainStore.dispatch(ChatListIsVisible())
      
      //chat view but different chatId
      if let userChatViewController = topController as? UserChatViewController {
        if userChatViewController.userChatId != userChatId {
          userChatViewController.navigationController?.popViewController(animated: true, completion: {
            if let userChatsController = CHUtils.getTopController() as? UserChatsViewController {
              userChatsController.showUserChat(userChatId: userChatId)
            }
          })
        }
      }
      //chat list
      else if let controller = topController as? UserChatsViewController {
        controller.showUserChat(userChatId: userChatId)
      }
      //no channel views
      else {
        let userChatsController = UserChatsViewController()
        userChatsController.showNewChat = userChatId == nil
        userChatsController.shouldHideTable = true
        if let userChatId = userChatId {
          userChatsController.goToUserChatId = userChatId
        }
        
        let controller = MainNavigationController(rootViewController: userChatsController)
        ChannelIO.baseNavigation = controller
        
        topController.present(controller, animated: animated, completion: nil)
      }
    }
  }
  
  internal class func showNotification(pushData: CHPush?) {
    guard let view = CHUtils.getTopController()?.baseController.view else { return }
    guard let push = pushData else { return }

    let notificationView = ChannelIO.chatNotificationView ?? ChatNotificationView()
    
    let notificationViewModel = ChatNotificationViewModel(push: push)
    notificationView.configure(notificationViewModel)
    
    if let superview = notificationView.superview, superview != view {
      notificationView.removeFromSuperview()
    }
    
    if notificationView.superview != view {
      notificationView.insert(on: view, animated: true)
    }
    
    let viewTopMargin = 20.f
    let viewSideMargin = 14.f
    let maxWidth = 520.f
    
    notificationView.snp.makeConstraints({ (make) in
      if UIScreen.main.bounds.width > maxWidth + viewSideMargin * 2 {
        make.centerX.equalToSuperview()
        make.width.equalTo(maxWidth)
      } else {
        make.leading.equalToSuperview().inset(viewSideMargin)
        make.trailing.equalToSuperview().inset(viewSideMargin)
      }
      
      if #available(iOS 11.0, *) {
        make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(viewTopMargin)
      } else {
        make.top.equalToSuperview().inset(viewTopMargin)
      }
    })
    
    notificationView
      .signalForChat()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (event) in
        ChannelIO.hideNotification()
        ChannelIO.showUserChat(userChatId: push.userChat?.id)
      }).disposed(by: disposeBag)
    
    notificationView.closeView
      .signalForClick()
      .observeOn(MainScheduler.instance)
      .subscribe { (event) in
        ChannelIO.hideNotification()
      }.disposed(by: disposeBag)
    
    notificationView
      .signalForRedirect()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (urlString) in
        guard let url = URL(string: urlString ?? "") else { return }
        let shouldHandle = ChannelIO.delegate?.onClickRedirect?(url: url)
        if shouldHandle == false || shouldHandle == nil {
          url.openWithUniversal()
        }
        ChannelIO.hideNotification()
      }).disposed(by: disposeBag)
    
    ChannelIO.chatNotificationView = notificationView
    CHAssets.playPushSound()
    
  }
  
  internal class func sendDefaultEvent(_ event: CHDefaultEvent, property: [String: Any]? = nil) {
    if ChannelIO.settings?.enabledTrackDefaultEvent == true {
      ChannelIO.track(eventName: event.rawValue, eventProperty: property)
    }
  }
    
  internal class func hideNotification() {
    guard ChannelIO.chatNotificationView != nil else { return }
    
    dispatch {
      mainStore.dispatch(RemovePush())
      ChannelIO.chatNotificationView?.remove(animated: true)
      ChannelIO.chatNotificationView = nil
    }
  }
}

extension ChannelIO {
  internal class func addNotificationObservers() {
    NotificationCenter.default.removeObserver(self)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.enterBackground),
      name: UIApplication.willResignActiveNotification,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.enterBackground),
      name: UIApplication.willTerminateNotification,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.enterForeground),
      name: UIApplication.didBecomeActiveNotification,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.appBecomeActive(_:)),
      name: UIApplication.willEnterForegroundNotification,
      object: nil)
  }
  
  @objc internal class func enterBackground() {
    WsService.shared.disconnect()
    ChannelIO.willBecomeActive = false
  }
  
  @objc internal class func enterForeground() {
    guard self.isValidStatus else { return }
    _ = AppManager.touch()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (guest) in
      mainStore.dispatch(UpdateGuest(payload: guest))
    })
    WsService.shared.connect()
  }
  
  @objc internal class func appBecomeActive(_ application: UIApplication) {
    ChannelIO.willBecomeActive = true
  }
}
