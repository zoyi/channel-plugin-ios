//
//  ChannelIO+Helper.swift
//  CHPlugin
//
//  Created by Haeun Chung on 29/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import RxSwift
import RxSwiftExt

extension ChannelIO {
  
  internal class func reset() {
    ChannelIO.launcherView?.hide(animated: false)
    ChannelIO.close(animated: false)
    ChannelIO.hideNotification()
    ChannelIO.launcherWindow = nil
    ChannelIO.lastPush = nil
    mainStore.dispatch(ShutdownSuccess())
    WsService.shared.disconnect()
    disposeBag = DisposeBag()
  }
  
  internal class func prepare() {
    if let subscriber = ChannelIO.subscriber {
      mainStore.unsubscribe(subscriber)
    }
    
    ChannelIO.reset()
  
    let subscriber = CHPluginSubscriber()
    mainStore.subscribe(subscriber)
    ChannelIO.subscriber = subscriber
  }

  internal class func bootChannel(profile: Profile? = nil) -> Observable<BootResponse> {
    return Observable.create { subscriber in
      guard let settings = ChannelIO.settings else {
        subscriber.onError(ChannelError.unknownError)
        return Disposables.create()
      }
      
      guard settings.pluginKey != "" else {
        subscriber.onError(ChannelError.parameterError)
        return Disposables.create()
      }
      
      if let memberId = settings.memberId, memberId != "" {
        PrefStore.setCurrentMemberId(memberId)
      } else {
        PrefStore.clearCurrentMemberId()
      }

      let params = BootParamBuilder()
        .with(memberId: settings.memberId)
        .with(profile: profile)
        .with(unsubscribed: settings.unsubscribed)
        .build()
      
      AppManager.shared
        .boot(pluginKey: settings.pluginKey, params: params)
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          dlog("Error while booting channelSDK. Attempting to boot again")
          return true
        })
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (result) in
          guard let result = result else {
            subscriber.onError(ChannelError.unknownError)
            return
          }
          
          if result.channel?.canUseSDK == false {
            subscriber.onError(ChannelError.serviceBlockedError)
            return
          }
          
          mainStore.dispatch(BootSuccess(payload: result))

          WsService.shared.connect()
          WsService.shared
            .ready()
            .take(1)
            .subscribe(onNext: { _ in
              subscriber.onNext(result)
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
    dispatch {
      guard let topController = CHUtils.getTopController() else {
        return
      }
      
      ChannelIO.launcherView?.hide(animated: false)
      mainStore.dispatch(ChatListIsVisible())
      
      //chat view but different chatId
      if let userChatView = topController as? UserChatView {
        if userChatView.presenter?.userChatId != userChatId {
          userChatView.navigationController?.popToRootViewController(animated: true, completion: {
            if let loungeView = CHUtils.getTopController() as? LoungeView,
              let presenter = loungeView.presenter as? LoungePresenter,
              let router = presenter.router {
              router.pushChat(with: userChatId, animated: animated, from: loungeView)
            }
          })
        }
      }
      //chat list
      else if let controller = topController as? UserChatsViewController {
        controller.showUserChat(userChatId: userChatId)
      }
      //lounge view
      else if let loungeView = CHUtils.getTopController() as? LoungeView,
        let presenter = loungeView.presenter as? LoungePresenter,
        let router = presenter.router {
        router.pushChat(with: userChatId, animated: animated, from: loungeView)
      }
      //no channel views
      else {
        let loungeView = LoungeRouter.createModule(with: userChatId)
        let controller = MainNavigationController(rootViewController: loungeView)
        ChannelIO.baseNavigation = controller
        loungeView
          .presenter?
          .isReadyToPresentChat(chatId: userChatId)
          .subscribe(onSuccess: { (_) in
            topController.present(controller, animated: animated, completion: nil)
          }, onError: { error in
            ChannelIO.open(animated: false)
          }).disposed(by: self.disposeBag)
      }
    }
  }
  
  internal class func showNotification(pushData: CHPushDisplayable?) {
    guard let push = pushData, !push.removed else { return }
    
    if ChannelIO.inAppNotificationView != nil {
      ChannelIO.inAppNotificationView?.removeView(animated: true)
      ChannelIO.inAppNotificationView = nil
    }
    
    var notificationView: InAppNotification?
    var view: UIView?
    let viewModel = InAppNotificationViewModel(push: push)
    
    if viewModel.mobileExposureType == .fullScreen {
      ChannelIO.launcherView?.hide(animated: true)
      notificationView = PopupInAppNotificationView()
      view = CHUtils.getKeyWindow()?.rootViewController?.view
    } else {
      notificationView = BannerInAppNotificationView()
      view = ChannelIO.launcherWindow?.rootViewController?.view
    }

    notificationView?.configure(with: viewModel)
    notificationView?.insertView(on: view)
    
    notificationView?
      .signalForChat()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (event) in
        ChannelIO.hideNotification()
        ChannelIO.showUserChat(userChatId: push.chatId)
      }).disposed(by: disposeBag)
    
    notificationView?
      .signalForClose()
      .observeOn(MainScheduler.instance)
      .subscribe { (event) in
        ChannelIO.hideNotification()
      }.disposed(by: disposeBag)
    
    if let mkInfo = push.mkInfo, viewModel.mobileExposureType == .fullScreen {
      mainStore.dispatch(ViewMarketing(type: mkInfo.type, id: mkInfo.id))
    }
    
    ChannelIO.inAppNotificationView = notificationView
    CHAssets.playPushSound()
  }
  
  internal class func sendDefaultEvent(_ event: CHDefaultEvent, property: [String: Any]? = nil) {
    if ChannelIO.settings?.enabledTrackDefaultEvent == true {
      ChannelIO.track(eventName: event.rawValue, eventProperty: property)
    }
  }
    
  internal class func hideNotification() {
    guard ChannelIO.inAppNotificationView != nil else { return }
    
    dispatch {
      mainStore.dispatch(RemovePush())
      ChannelIO.inAppNotificationView?.removeView(animated: true)
      ChannelIO.inAppNotificationView = nil
    }
  }
  
  internal class func didDismiss() {
    mainStore.dispatch(ChatListIsHidden())
    if ChannelIO.launcherVisible {
      ChannelIO.launcherView?.show(animated: true)
    }
    
    ChannelIO.baseNavigation?.removeFromParent()
    ChannelIO.baseNavigation = nil
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
  
  internal class func removeNotificationObservers() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc internal class func enterBackground() {
    WsService.shared.disconnect()
    ChannelIO.willBecomeActive = false
    ChannelAvailabilityChecker.shared.stop()
    NotificationCenter.default.post(name: Notification.Name.Channel.enterBackground, object: nil)
  }
  
  @objc internal class func enterForeground() {
    guard self.isValidStatus else { return }
    _ = WsService.shared.ready()
      .take(1)
      .flatMap({ (_) -> Observable<BootResponse> in
        return AppManager.shared.touch()
      })
      .subscribe(onNext: { (result) in
        mainStore.dispatch(GetTouchSuccess(payload: result))
      })

    WsService.shared.connect()
    NotificationCenter.default.post(name: Notification.Name.Channel.enterForeground, object: nil)
  }
  
  @objc internal class func appBecomeActive(_ application: UIApplication) {
    ChannelIO.willBecomeActive = true
    if ChannelIO.baseNavigation != nil {
      ChannelAvailabilityChecker.shared.run()
    }
  }
}
