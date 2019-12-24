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
    mainStore.dispatch(ShutdownSuccess())
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

  internal class func bootChannel(profile: Profile? = nil) -> Observable<BootResult> {
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
          guard let channel = data.channel else {
            subscriber.onError(CHErrorPool.unknownError)
            return
          }

          if !channel.canUseSDK {
            subscriber.onError(CHErrorPool.serviceBlockedError)
            return
          }
          
          mainStore.dispatch(BootSuccess(payload: data))
          WsService.shared.connect()
          WsService.shared
            .ready()
            .take(1)
            .subscribe(onNext: { _ in
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
    dispatch {
      guard let topController = CHUtils.getTopController() else {
        return
      }
      
      ChannelIO.launcherView?.hide(animated: false)
      mainStore.dispatch(ChatListIsVisible())
      
      //chat view but different chatId
      if let userChatViewController = topController as? UserChatViewController {
        if userChatViewController.userChatId != userChatId {
          userChatViewController.navigationController?.popToRootViewController(animated: true, completion: {
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
        
        loungeView.presenter?.isReadyToPresentChat(chatId: userChatId)
          .subscribe(onSuccess: { (_) in
            topController.present(controller, animated: animated, completion: nil)
          }, onError: { (error) in
            
          }).disposed(by: self.disposeBag)
      }
    }
  }
  
  internal class func showNotification(pushData: CHPush?) {
    guard let view = ChannelIO.launcherWindow?.rootViewController?.view else { return }
    guard let push = pushData else { return }
    
    if ChannelIO.inAppNotificationView != nil {
      ChannelIO.inAppNotificationView?.removeView(animated: true)
      ChannelIO.inAppNotificationView = nil
    }
    
    var notificationView: InAppNotification?
    if !push.isNudgePush || push.mobileExposureType == .banner {
      notificationView = BannerInAppNotificationView()
    } else {
      notificationView = PopupInAppNotificationView()
    }
    
    let viewModel = InAppNotificationViewModel(push: push)
    notificationView?.configure(with: viewModel)
    notificationView?.insertView(on: view)
    
    notificationView?
      .signalForChat()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (event) in
        ChannelIO.hideNotification()
        ChannelIO.showUserChat(userChatId: push.userChat?.id)
      }).disposed(by: disposeBag)
    
    notificationView?
      .signalForClose()
      .observeOn(MainScheduler.instance)
      .subscribe { (event) in
        ChannelIO.hideNotification()
      }.disposed(by: disposeBag)
    
    notificationView?
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
    NotificationCenter.default.post(name: Notification.Name.Channel.enterBackground, object: nil)
  }
  
  @objc internal class func enterForeground() {
    guard self.isValidStatus else { return }
    _ = WsService.shared.ready()
      .take(1)
      .flatMap({ (_) -> Observable<CHGuest> in
        return AppManager.touch()
      })
      .subscribe(onNext: { (guest) in
        mainStore.dispatch(UpdateGuest(payload: guest))
      })

    WsService.shared.connect()
    NotificationCenter.default.post(name: Notification.Name.Channel.enterForeground, object: nil)
  }
  
  @objc internal class func appBecomeActive(_ application: UIApplication) {
    ChannelIO.willBecomeActive = true
  }
}
