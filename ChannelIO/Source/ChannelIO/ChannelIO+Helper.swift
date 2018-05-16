//
//  ChannelIO+Helper.swift
//  CHPlugin
//
//  Created by Haeun Chung on 29/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import RxSwift
import CRToast
import SVProgressHUD

extension ChannelIO {
  internal class func prepare() {
    if let subscriber = ChannelIO.subscriber {
      mainStore.unsubscribe(subscriber)
      ChannelIO.hide(animated: false)
      ChannelIO.close(animated: false)
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
    
    ChannelIO.initWebsocket()
    let subscriber = CHPluginSubscriber()
    mainStore.subscribe(subscriber)
    ChannelIO.subscriber = subscriber
    
    CRToastManager.setDefaultOptions(toastOptions)
    SVProgressHUD.setDefaultStyle(.dark)
  }
  
  internal class func track(
    eventName: String,
    eventProperty: [String: Any]?,
    sysProperty: [String: Any]?) {
    if eventName.utf16.count > 30 || eventName == "" {
      return
    }
    
    EventPromise.sendEvent(
      name: eventName,
      properties: eventProperty,
      sysProperties: sysProperty)
      .subscribe(onNext: { (event) in
        dlog("\(eventName) event sent successfully")
      }, onError: { (error) in
        dlog("\(eventName) event failed")
      }).disposed(by: self.disposeBeg)
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

      var params = [String: Any]()
      if let profile = profile {
        params["body"] = profile.generateParams()
      }
      
      if let userId = settings.userId, userId != "" {
        PrefStore.setCurrentUserId(userId: userId)
      } else {
        PrefStore.clearCurrentUserId()
      }
      
      PluginPromise
        .boot(pluginKey: settings.pluginKey, params: params)
        .subscribe(onNext: { (data) in
          var data = data
          let channel = data["channel"] as! CHChannel
          if channel.shouldBlock && !channel.trial {
            subscriber.onError(CHErrorPool.serviceBlockedError)
            return
          }
          
          data["settings"] = settings
          
          WsService.shared.connect()
          mainStore.dispatch(UpdateCheckinState(payload: .success))
          mainStore.dispatch(CheckInSuccess(payload: data))
        
          ChannelIO.sendDefaultEvent(.boot)
          
          WsService.shared.ready().subscribe(onNext: { _ in
            subscriber.onNext(data)
            subscriber.onCompleted()
          }).disposed(by: self.disposeBeg)
          
        }, onError: { error in
          subscriber.onError(error)
        }, onCompleted: {
          dlog("Check in complete")
        }).disposed(by: self.disposeBeg)
      
      return Disposables.create()
    }
  }
  
  internal class func showUserChat(userChatId: String?) {
    guard let topController = CHUtils.getTopController() else {
      return
    }
    
    ChannelIO.sendDefaultEvent(.open)
    mainStore.dispatch(ChatListIsVisible())
    
    if let userChatViewController = topController as? UserChatViewController,
      userChatViewController.userChatId == userChatId {
      //do nothing
    } else if topController is UserChatsViewController {
      let userChatsController = topController as! UserChatsViewController
      userChatsController.showUserChat(userChatId: userChatId)
    } else if topController is UserChatViewController {
      topController.navigationController?.popViewController(animated: false, completion: {
        let userChatsController = CHUtils.getTopController() as! UserChatsViewController
        userChatsController.showUserChat(userChatId: userChatId)
      })
    } else {
      let userChatsController = UserChatsViewController()
      userChatsController.showNewChat = userChatId == nil
      userChatsController.shouldHideTable = true
      if let userChatId = userChatId {
        userChatsController.goToUserChatId = userChatId
      }
      
      let controller = MainNavigationController(rootViewController: userChatsController)
      ChannelIO.baseNavigation = controller
      
      topController.present(controller, animated: true, completion: nil)
    }
  }
  
  internal class func registerPushToken() {
    guard let pushToken = ChannelIO.pushToken else { return }
    
    let channelId = mainStore.state.channel.id
    
    PluginPromise
      .registerPushToken(channelId: channelId, token: pushToken)
      .subscribe(onNext: { (result) in
        dlog("register token success")
      }
      ,onError:{ error in
        dlog("register token failed")
      }).disposed(by: disposeBeg)
  }
  
  internal class func showNotification(pushData: CHPush?) {
    guard let topController = CHUtils.getTopController(), let push = pushData else {
      return
    }
    
    ChannelIO.hideNotification()
    
    let notificationView = ChatNotificationView()
    notificationView.topLayoutGuide = topController.topLayoutGuide
    
    let notificationViewModel = ChatNotificationViewModel(push: push)
    notificationView.configure(notificationViewModel)
    notificationView.show(onView: topController.view, animated: true)
    
    notificationView.signalForClick()
      .subscribe(onNext: { (event) in
        self.hideNotification()
        self.showUserChat(userChatId: push.userChat?.id)
      }).disposed(by: self.disposeBeg)
    
    notificationView.closeView.signalForClick()
      .subscribe { (event) in
        self.hideNotification()
      }.disposed(by: self.disposeBeg)
    
    self.chatNotificationView = notificationView
    
    // create a sound ID, in this case its the tweet sound.
    // to play sound
    if PrefStore.getPushSoundOption() {
      CHAssets.playPushSound()
    }
    
    mainStore.dispatch(RemovePush())
  }
  
  internal class func sendDefaultEvent(_ event: CHDefaultEvent, property: [String: Any]? = nil) {
    if ChannelIO.settings?.enabledTrackDefaultEvent == true {
      ChannelIO.track(eventName: event.rawValue, eventProperty: property)
    }
  }
  
  internal class func hideNotification() {
    guard ChannelIO.chatNotificationView != nil else { return }
    
    mainStore.dispatch(RemovePush())
    ChannelIO.chatNotificationView?.remove(animated: true)
    ChannelIO.chatNotificationView = nil
  }
}

extension ChannelIO {
  internal class func initWebsocket() {
    NotificationCenter.default.removeObserver(self)
    
    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(self.disconnectWebsocket),
        name: NSNotification.Name.UIApplicationWillResignActive,
        object: nil)
    
    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(self.disconnectWebsocket),
        name: NSNotification.Name.UIApplicationWillTerminate,
        object: nil)
    
    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(self.connectWebsocket),
        name: NSNotification.Name.UIApplicationDidBecomeActive,
        object: nil)
    
    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(self.appBecomeActive(_:)),
        name: Notification.Name.UIApplicationWillEnterForeground,
        object: nil)
  }
  
  @objc internal class func disconnectWebsocket() {
    WsService.shared.disconnect()
  }
  
  @objc internal class func connectWebsocket() {
    WsService.shared.connect()
  }
  
  @objc internal class func appBecomeActive(_ application: UIApplication) {
    guard self.isValidStatus else { return }
    _ = GuestPromise.getCurrent().subscribe(onNext: { (user) in
      mainStore.dispatch(UpdateGuest(payload: user))
    })
  }
}
