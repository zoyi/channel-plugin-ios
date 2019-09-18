//
//  ChannelIO.swift
//  ChannelIO
//
//  Created by intoxicated on 2017. 1. 10..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import SnapKit
import ReSwift
import RxSwift
import UserNotifications

internal let mainStore = Store<AppState>(
  reducer: appReducer,
  state: nil,
  middleware: [loggingMiddleware]
)

internal func dlog(_ str: String) {
  guard ChannelIO.settings?.debugMode == true else { return }
  print("[ChannelIO]: \(str)")
}

@objc
public protocol ChannelPluginDelegate: class {
  @objc optional func onChangeBadge(count: Int) -> Void /* notify badge count when changed */
  @objc optional func onClickChatLink(url: URL) -> Bool /* notifiy if a link is clicked */
  @objc optional func willShowMessenger() -> Void /* notify when chat list is about to show */
  @objc optional func willHideMessenger() -> Void /* notify when chat list is about to hide */
  @objc optional func onReceivePush(event: PushEvent) -> Void /* notifiy when new push message arrives */
  @objc optional func onClickRedirect(url: URL) -> Bool /* notify when a user click on a link */
  @objc optional func onChangeProfile(key: String, value: Any?) -> Void /* notify when the guest profile has been changed */
}

@objc
public final class ChannelIO: NSObject {
  //MARK: Properties
  @objc public static weak var delegate: ChannelPluginDelegate? = nil
  @objc public static var isBooted: Bool {
    return mainStore.state.checkinState.status == .success
  }
  @objc public static var canShowLauncher: Bool {
    return !mainStore.state.channel.shouldHideLauncher && ChannelIO.isValidStatus
  }
  
  internal static var inAppNotificationView: InAppNotification?
  internal static var baseNavigation: BaseNavigationController? {
    willSet {
      if ChannelIO.baseNavigation == nil && newValue != nil {
        ChannelAvailabilityChecker.shared.run()
      } else {
        ChannelAvailabilityChecker.shared.stop()
      }
    }
  }
  internal static var subscriber : CHPluginSubscriber?

  internal static var disposeBag = DisposeBag()
  internal static var pushToken: String?
  internal static var currentAlertCount: Int? = nil

  static var isValidStatus: Bool {
    return mainStore.state.checkinState.status == .success &&
      mainStore.state.channel.id != ""
  }

  internal static var settings: ChannelPluginSettings? = nil
  internal static var profile: Profile? = nil
  internal static var lastPush: CHPush?
  
  internal static var launcherView: LauncherView? = nil
  internal static var launcherVisible: Bool = false
  internal static var willBecomeActive: Bool = true
  
  // MARK: StoreSubscriber
  class CHPluginSubscriber : StoreSubscriber {
    //refactor into two selectors
    func newState(state: AppState) {
      dispatch {
        self.handleBadge(state.guest.alert)
        self.handlePush(push: state.push)
        
        let viewModel = LauncherViewModel(
          plugin: state.plugin,
          guest: state.guest,
          push: ChannelIO.lastPush
        )
        ChannelIO.launcherView?.configure(viewModel)
      }
    }
    
    func handlePush (push: CHPush?) {
      guard let push = push else { return }
      
      if ChannelIO.baseNavigation == nil &&
        ChannelIO.settings?.hideDefaultInAppPush == false &&
        ChannelIO.lastPush != push {
        ChannelIO.showNotification(pushData: push)
      }
      
      if ChannelIO.lastPush != push {
        ChannelIO.delegate?.onReceivePush?(event: PushEvent(with: push))
        ChannelIO.lastPush = push
      }
    }
    
    func handleBadge(_ count: Int?) {
      guard let count = count else { return }
      
      if let curr = ChannelIO.currentAlertCount, curr != count {
        ChannelIO.delegate?.onChangeBadge?(count: count)
      }
      ChannelIO.currentAlertCount = count
    }
  }
  
  // MARK: Public

  /**
   *  Initialize ChannelIO
   *
   *  - parameter application: application instance
   */
  @objc
  public class func initialize(_ application: UIApplication) {
    ChannelIO.addNotificationObservers()
  }
  
  /**
   *   Boot ChannelIO
   *
   *   Boot up ChannelIO and make it ready to use
   *
   *   - parameter settings: ChannelPluginSettings object
   *   - parameter guest: Guest object
   *   - parameter compeltion: ChannelPluginCompletionStatus indicating status of boot phase
   */
  @objc
  public class func boot(
    with settings: ChannelPluginSettings,
    profile: Profile? = nil,
    completion: ((ChannelPluginCompletionStatus, Guest?) -> Void)? = nil) {
    
    dispatch {
      ChannelIO.prepare()
      ChannelIO.settings = settings
      ChannelIO.profile = profile
      
      if settings.pluginKey == "" {
        mainStore.dispatch(UpdateCheckinState(payload: .notInitialized))
        completion?(.notInitialized, nil)
        return
      }
      
      AppManager.checkVersion().flatMap { (event) in
        return ChannelIO.checkInChannel(profile: profile)
      }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (_) in
        PrefStore.setChannelPluginSettings(pluginSetting: settings)
        AppManager.registerPushToken()
        
        if ChannelIO.launcherVisible {
          ChannelIO.show(animated: true)
        }
        completion?(.success, Guest(with: mainStore.state.guest))
      }, onError: { error in
        let code = (error as NSError).code
        if code == -1001 {
          dlog("network timeout")
          mainStore.dispatch(UpdateCheckinState(payload: .networkTimeout))
          completion?(.networkTimeout, nil)
        } else if code == CHErrorCode.versionError.rawValue {
          dlog("version is not compatiable. please update sdk version")
          mainStore.dispatch(UpdateCheckinState(payload: .notAvailableVersion))
          completion?(.notAvailableVersion, nil)
        } else if code == CHErrorCode.serviceBlockedError.rawValue {
          dlog("require payment. free plan is not eligible to use SDK")
          mainStore.dispatch(UpdateCheckinState(payload: .requirePayment))
          completion?(.requirePayment, nil)
        } else {
          dlog("unknown")
          mainStore.dispatch(UpdateCheckinState(payload: .unknown))
          completion?(.unknown, nil)
        }
      }).disposed(by: disposeBag)
    }
  }

  /**
   *   Init a push token.
   *   This method has to be called within
   *   `application:didRegisterForRemoteNotificationsWithDeviceToken:`
   *   in `AppDelegate` in order to get receive push notification from Channel io
   *
   *   - parameter deviceToken: a Data that represents device token
   */
  @objc
  public class func initPushToken(deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    ChannelIO.pushToken = token
    
    if ChannelIO.isValidStatus {
      AppManager.registerPushToken()
    }
  }
  
  @objc
  public class func initPushToken(tokenString: String) {
    ChannelIO.pushToken = tokenString
    
    if ChannelIO.isValidStatus {
      AppManager.registerPushToken()
    }
  }

  /**
   *   Shutdown ChannelIO
   *   Call this method when user terminate session or logout
   */
  @objc
  public class func shutdown() {
    let guestToken = PrefStore.getCurrentGuestKey() ?? ""
    dispatch {
      ChannelIO.reset()
    }
    AppManager.unregisterToken(token: guestToken)
  }
    
  /**
   *   Show channel launcher on application
   *   location of the view can be customized with LauncherConfig property in ChannelPluginSettings
   *
   *   - parameter animated: if true, the view is being added to the window using an animation
   */
  @objc
  public class func show(animated: Bool) {
    dispatch {
      guard let view = CHUtils.getTopController()?.baseController.view else { return }
      
      ChannelIO.launcherVisible = true
      guard ChannelIO.isValidStatus, ChannelIO.canShowLauncher else { return }
      guard ChannelIO.baseNavigation == nil else { return }
      
      let launcherView = ChannelIO.launcherView ?? LauncherView()
      
      let viewModel = LauncherViewModel(
        plugin: mainStore.state.plugin,
        guest: mainStore.state.guest,
        push: mainStore.state.push
      )
      
      let xMargin = ChannelIO.settings?.launcherConfig?.xMargin ?? 24
      let yMargin = ChannelIO.settings?.launcherConfig?.yMargin ?? 24
      let position = ChannelIO.settings?.launcherConfig?.position ?? .right
      
      if launcherView.superview == nil ||
        launcherView.superview != view ||
        launcherView.alpha == 0 {
        if let topController = CHUtils.getTopController() {
          ChannelIO.sendDefaultEvent(.pageView, property: [
            TargetKey.url.rawValue: "\(type(of: topController))"
          ])
        } else {
          ChannelIO.sendDefaultEvent(.pageView)
        }
      }
      
      if let superview = launcherView.superview, superview != view {
        launcherView.removeFromSuperview()
      }
      
      launcherView.superview != view ?
        launcherView.insert(on: view, animated: animated) :
        launcherView.show(animated: animated)
      
      launcherView.snp.remakeConstraints ({ (make) in
        make.size.equalTo(CGSize(width:50.f, height:50.f))
        
        if position == LauncherPosition.right {
          make.right.equalToSuperview().inset(xMargin)
        } else if position == LauncherPosition.left {
          make.left.equalToSuperview().inset(xMargin)
        }
        
        if #available(iOS 11.0, *) {
          make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-yMargin)
        } else {
          make.bottom.equalToSuperview().inset(yMargin)
        }
      })
      
      launcherView.configure(viewModel)
      launcherView.buttonView.signalForClick().subscribe(onNext: { _ in
        guard ChannelIO.isValidStatus else { return }
        ChannelIO.hideNotification()
        ChannelIO.open(animated: true)
      }).disposed(by: disposeBag)
      
      ChannelIO.launcherView = launcherView
    }
  }
  
  /**
   *  Hide channel launcher from application
   *
   *  - parameter animated: if true, the view is being added to the window using an animation
   */
  @objc
  public class func hide(animated: Bool) {
    dispatch {
      ChannelIO.launcherView?.hide(animated: animated)
      ChannelIO.launcherVisible = false
    }
  }
  
  /** 
   *   Open channel messenger on application
   *
   *   - parameter animated: if true, the view is being added to the window using an animation
   */
  @objc
  public class func open(animated: Bool) {
    dispatch {
      guard ChannelIO.isValidStatus else { return }
      guard !mainStore.state.uiState.isChannelVisible else { return }
      guard let topController = CHUtils.getTopController() else { return }
      
      ChannelIO.launcherView?.isHidden = true
      ChannelIO.delegate?.willShowMessenger?()

      mainStore.dispatch(ChatListIsVisible())
      let loungeView = LoungeRouter.createModule()
      let controller = MainNavigationController(rootViewController: loungeView)
//      if #available(iOS 13, *) {
//        controller.isModalInPresentation = true
//      }
      ChannelIO.baseNavigation = controller

      topController.present(controller, animated: animated, completion: nil)
    }
  }

  /**
   *   Close channel messenger from application
   *
   *   - parameter animated: if true, the view is being added to the window using an animation
   */
  @objc
  public class func close(animated: Bool, completion: (() -> Void)? = nil) {
    guard ChannelIO.isValidStatus else { completion?(); return }
    guard mainStore.state.uiState.isChannelVisible else { completion?(); return }
    guard ChannelIO.baseNavigation != nil else { completion?(); return }
    
    dispatch {
      ChannelIO.delegate?.willHideMessenger?()
      ChannelIO.baseNavigation?.dismiss(animated: animated, completion: {
        ChannelIO.didDismiss()
        completion?()
      })
    }
  }
  
  /**
   *  Open a user chat with given chat id
   *
   *  - parameter chatId: a String user chat id. Will open new chat if chat id is invalid
   *  - parameter completion: a closure to signal completion state
   */
  @objc
  public class func openChat(with chatId: String? = nil, animated: Bool) {
    guard ChannelIO.isValidStatus else { return }
    ChannelIO.showUserChat(userChatId: chatId, animated: animated)
  }
  
  /**
   *  Update user profile (objective-c)
   *
   *  - parameter profile: a dictionary with profile key and profile value pair. Set a value to nil
   *                       to remove existing value
   */
  @objc
  public class func updateGuest(_ profile: [String: Any], completion: ((Bool, Guest?) -> Void)? = nil) {
    let profile:[String: Any?] = profile.mapValues { (value) -> Any? in
      return value is NSNull ? nil : value
    }
    ChannelIO.updateGuest(with: profile, completion: completion)
  }
  
  /**
   *  Update user profile
   *
   *  - parameter profile: a dictionary with profile key and profile value pair. Set a value to nil
   *                       to remove existing value
   */
  public class func updateGuest(with profile: [String: Any?], completion: ((Bool, Guest?) -> Void)? = nil) {
    GuestPromise.updateProfile(with: profile)
      .subscribe(onNext: { (guest, error) in
        if let guest = guest {
          completion?(true, Guest(with: guest))
        } else {
          completion?(false, nil)
        }
      }, onError: { error in
        completion?(false, nil)
      }).disposed(by: disposeBag)
  }
  
  /**
   *  Track an event
   *
   *   - parameter eventName: Event name
   *   - parameter eventProperty: a Dictionary contains information about event
   */
  @objc
  public class func track(eventName: String, eventProperty: [String: Any]? = nil) {
    guard ChannelIO.isValidStatus else { return }
    
    dispatch {
      let version = Bundle(for: ChannelIO.self)
        .infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
      
      dlog("[CHPlugin] Track \(eventName) property \(eventProperty ?? [:])")
    
      var sysProperty: [String: Any] = [
        "pluginVersion": version,
        "screenWidth": UIScreen.main.bounds.width,
        "screenHeight": UIScreen.main.bounds.height
      ]

      if let pageName = eventProperty?["url"] {
        sysProperty["url"] = pageName
      } else if let controller = CHUtils.getTopController() {
        sysProperty["url"] = "\(type(of: controller))"
      }
      
      ChannelIO.track(eventName: eventName, eventProperty: eventProperty, sysProperty: sysProperty)
    }
  }
  
  /**
   *   Check whether push notification is valid Channel push notification
   *   by inspecting userInfo
   *
   *   - parameter userInfo: a Dictionary contains push information
   */
  @objc
  public class func isChannelPushNotification(_ userInfo:[AnyHashable: Any]) -> Bool {
    guard let provider = userInfo["provider"] as? String, provider  == CHConstants.channelio else { return false }
    guard let personType = userInfo["personType"] as? String else { return false }
    guard let personId = userInfo["personId"] as? String else { return false }
    guard let pushChannelId = userInfo["channelId"] as? String else { return false }

    let userId = PrefStore.getCurrentUserId() ?? ""
    let veilId = PrefStore.getCurrentVeilId() ?? ""
    let channelId = PrefStore.getCurrentChannelId() ?? ""
    
    if personType == "User" {
      return personId == userId && pushChannelId == channelId
    }
    
    if personType == "Veil" {
      return personId == veilId && pushChannelId == channelId
    }
    
    return false
  }
  
  /**
   *   Handle push notification for channel
   *   This method has to be called within `userNotificationCenter:response:completionHandler:`
   *   for **iOS 10 and above**, and `application:userInfo:completionHandler:`
   *   for **other version of iOS** in `AppDelegate` in order to make channel
   *   plugin worked properly
   *
   *   - parameter userInfo: a Dictionary contains push information
   *   - parameter completion: closure that will get called when completed
   */
  @objc
  public class func handlePushNotification(_ userInfo:[AnyHashable : Any], completion: (() -> Void)? = nil) {
    guard ChannelIO.isChannelPushNotification(userInfo) else { return }
    guard let userChatId = userInfo["chatId"] as? String else { return }
    
    //not tap and signal server to acknowledgement
    if !ChannelIO.willBecomeActive {
      AppManager.sendAck(userChatId: userChatId).subscribe(onNext: { (completed) in
        completion?()
      }, onError: { (error) in
        completion?()
      }).disposed(by: self.disposeBag)
      return
    }
    
    if ChannelIO.isValidStatus {
      ChannelIO.showUserChat(userChatId:userChatId)
      completion?()
      return
    }
    
    guard let settings = PrefStore.getChannelPluginSettings() else {
      dlog("ChannelPluginSetting is missing")
      completion?()
      return
    }
    
    if let userId = PrefStore.getCurrentUserId() {
      settings.userId = userId
    }
    
    ChannelIO.boot(with: settings, profile: profile) { (status, guest) in
      if status == .success {
        ChannelIO.showUserChat(userChatId:userChatId)
      }
      completion?()
    }
  }
}
