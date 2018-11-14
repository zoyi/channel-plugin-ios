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
  internal class func reset() {
    dispatch {
      ChannelIO.launcherView?.hide(animated: false)
      ChannelIO.close(animated: false)
      ChannelIO.hideNotification()
      mainStore.dispatch(CheckOutSuccess())
      WsService.shared.disconnect()
    }
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
    if eventName == "Boot" {
      ChannelIO.pushBotProcess(actionName: eventName)
    }
    EventPromise.sendEvent(
      name: eventName,
      properties: eventProperty,
      sysProperties: sysProperty).subscribe(onNext: { (event) in
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
      
      PluginPromise
        .boot(pluginKey: settings.pluginKey, params: params)
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
          
          WsService.shared.connect()
          mainStore.dispatch(UpdateCheckinState(payload: .success))
          mainStore.dispatch(CheckInSuccess(payload: data))
        
          ChannelIO.sendDefaultEvent(.boot)
          
          WsService.shared.ready().take(1).subscribe(onNext: { _ in
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
  
  internal class func showUserChat(userChatId: String?, animated: Bool = true) {
    guard let topController = CHUtils.getTopController() else {
      return
    }
    
    dispatch {
      ChannelIO.launcherView?.isHidden = true
      ChannelIO.sendDefaultEvent(.open)
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
  
  internal class func registerPushToken() {
    guard let pushToken = ChannelIO.pushToken else { return }
    
    PluginPromise
      .registerPushToken(channelId: mainStore.state.channel.id, token: pushToken)
      .subscribe(onNext: { (result) in
        dlog("register token success")
      }, onError:{ error in
        dlog("register token failed")
      }).disposed(by: disposeBeg)
  }
  
  internal class func showNotification(pushData: CHPush?) {
    guard let topController = CHUtils.getTopController(), let push = pushData else {
      return
    }
    
    dispatch {
      ChannelIO.hideNotification()
      
      let notificationView = ChatNotificationView()
      notificationView.topLayoutGuide = topController.topLayoutGuide
      
      let notificationViewModel = ChatNotificationViewModel(push: push)
      notificationView.configure(notificationViewModel)
      notificationView.insert(on: topController.view, animated: true)
      
      notificationView
        .signalForChat()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (event) in
          ChannelIO.hideNotification()
          ChannelIO.showUserChat(userChatId: push.userChat?.id)
        }).disposed(by: self.disposeBeg)
      
      notificationView.closeView
        .signalForClick()
        .observeOn(MainScheduler.instance)
        .subscribe { (event) in
          ChannelIO.hideNotification()
        }.disposed(by: self.disposeBeg)
      
      notificationView.redirectSignal
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (urlString) in
          guard let url = URL(string: urlString ?? "") else { return }
          let shouldHandle = ChannelIO.delegate?.onClickChatLink?(url: url)
          if shouldHandle == false || shouldHandle == nil {
            url.openWithUniversal()
          }
        }).disposed(by: self.disposeBeg)
      
      ChannelIO.chatNotificationView = notificationView
      CHAssets.playPushSound()
      mainStore.dispatch(RemovePush())
    }
  }
  
  internal class func sendDefaultEvent(_ event: CHDefaultEvent, property: [String: Any]? = nil) {
    if ChannelIO.settings?.enabledTrackDefaultEvent == true {
      ChannelIO.track(eventName: event.rawValue, eventProperty: property)
    }
  }
    
  internal class func hideNotification() {
    guard ChannelIO.chatNotificationView != nil else { return }

    ChannelIO.chatNotificationView?.remove(animated: true)
    ChannelIO.chatNotificationView = nil
  }
  
  
  internal class func processPushBot(actionName: String) {
    //guard mainStore.state.channel.pushBotPlan == .pro else { return }
    let guest = mainStore.state.guest
    
    NudgePromise.getNudges(pluginId: mainStore.state!.plugin.id)
      .flatMap({ (nudges) -> Observable<CHNudge> in
        var filtered: [CHNudge] = []
        for nudge in nudges {
          let eval = TargetEvaluatorService
            .evaluate(
              object: nudge,
              userInfo: guest.userInfo.merging(
                [TargetKey.url.rawValue: actionName],
                uniquingKeysWith: { (_, second) in second }
              )
            )
          eval ? filtered.append(nudge) : nil
        }
        return Observable.from(filtered)
      })
      .flatMap ({ (nudge) -> Observable<CHNudge> in
        return Observable.just(nudge)
          .delay(
            Double(nudge.triggerDelay),
            scheduler: MainScheduler.instance
          )
      })
      .concatMap ({ (nudge) -> Observable<NudgeReachResponse> in
        return NudgePromise.requestReach(nudgeId: nudge.id)
      })
      .takeWhile { $0.reach == true }
      .take(1)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (response) in
        let (chat, message, session) = CHUserChat.createLocal(
          writer: response.bot,
          variant: response.variant
        )
        mainStore.dispatch(
          CreateLocalUserChat(
            chat: chat,
            message: message,
            writer: response.bot,
            session: session
          )
        )
        guard ChannelIO.baseNavigation == nil else { return }
        if let chat = chat, let message = message {
          ChannelIO.showNotification(pushData: CHPush(
            chat: chat,
            message: message,
            response: response
          ))
        }
        
      }, onError: { (error) in
        //
      }).disposed(by: disposeBeg)
  }
}

extension ChannelIO {
  internal class func addNotificationObservers() {
    NotificationCenter.default.removeObserver(self)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.enterBackground),
      name: NSNotification.Name.UIApplicationWillResignActive,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.enterBackground),
      name: NSNotification.Name.UIApplicationWillTerminate,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.enterForeground),
      name: NSNotification.Name.UIApplicationDidBecomeActive,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.appBecomeActive(_:)),
      name: Notification.Name.UIApplicationWillEnterForeground,
      object: nil)
  }
  
  @objc internal class func enterBackground() {
    WsService.shared.disconnect()
    ChannelIO.willBecomeActive = false
  }
  
  @objc internal class func enterForeground() {
    guard self.isValidStatus else { return }
    _ = GuestPromise.touch()
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
