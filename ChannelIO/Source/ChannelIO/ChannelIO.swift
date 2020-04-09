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
import SDWebImageWebPCoder

internal let mainStore = Store<AppState>(
  reducer: appReducer,
  state: nil,
  middleware: [
    createMiddleware(marketingStatHook())
  ]
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
  @objc optional func onChangeProfile(key: String, value: Any?) -> Void /* notify when the user profile has been changed */
}

@objc
public final class ChannelIO: NSObject {
  //MARK: Properties
  @objc public static weak var delegate: ChannelPluginDelegate?
  @objc public static var isBooted: Bool {
    return mainStore.state.bootState.status == .success
  }
  @objc public static var canShowLauncher: Bool {
    return !mainStore.state.channel.shouldHideLauncher && ChannelIO.isValidStatus
  }
  
  internal static var inAppNotificationView: InAppNotification? {
    get {
      return ChannelIO.launcherWindow?.inAppNotificationView
    }
    set {
      ChannelIO.launcherWindow?.inAppNotificationView = newValue
    }
  }
  
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
  internal static var currentAlertCount: Int?

  static var isValidStatus: Bool {
    return mainStore.state.bootState.status == .success &&
      mainStore.state.channel.id != ""
  }

  internal static var settings: ChannelPluginSettings?
  internal static var profile: Profile?
  internal static var lastPush: CHPushDisplayable?
  
  internal static var hostTopControllerName: String?
  internal static var launcherView: LauncherView? {
    get {
      return ChannelIO.launcherWindow?.launcherView
    }
    set {
      ChannelIO.launcherWindow?.launcherView = newValue
    }
  }
  internal static var launcherWindow: LauncherWindow?

  internal static var launcherVisible: Bool = false
  internal static var willBecomeActive: Bool = false
  
  // MARK: StoreSubscriber
  class CHPluginSubscriber : StoreSubscriber {
    //refactor into two selectors
    func newState(state: AppState) {
      dispatch {
        self.handleBadge(state.user.alert)
        self.handlePush(push: state.push)
        
        let viewModel = LauncherViewModel(
          plugin: state.plugin,
          user: state.user,
          push: ChannelIO.lastPush
        )
        ChannelIO.launcherView?.configure(viewModel)
      }
    }
    
    func handlePush (push: CHPushDisplayable?) {
      guard let push = push else { return }
      
      if ChannelIO.baseNavigation == nil &&
        ChannelIO.settings?.hideDefaultInAppPush == false &&
        !push.isEqual(to: ChannelIO.lastPush) {
        ChannelIO.showNotification(pushData: push)
      }
      
      if !push.isEqual(to: ChannelIO.lastPush) {
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
    
    let coder = SDImageWebPCoder.shared
    SDImageCodersManager.shared.addCoder(coder)
  }
  
  /**
   *   Boot ChannelIO
   *
   *   Boot up ChannelIO and make it ready to use
   *
   *   - parameter settings: ChannelPluginSettings object
   *   - parameter user: User object
   *   - parameter compeltion: ChannelPluginCompletionStatus indicating status of boot phase
   */
  @objc
  public class func boot(
    with settings: ChannelPluginSettings,
    profile: Profile? = nil,
    completion: ((ChannelPluginCompletionStatus, User?) -> Void)? = nil) {
    
    dispatch {
      ChannelIO.settings = settings
      ChannelIO.profile = profile
      ChannelIO.prepare()
      
      if settings.pluginKey == "" {
        mainStore.dispatch(UpdateBootState(payload: .notInitialized))
        completion?(.notInitialized, nil)
        return
      }
      
      AppManager.shared
        .checkVersion()
        .flatMap { (event) in
          return ChannelIO.bootChannel(profile: profile)
        }
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (_) in
          PrefStore.setChannelPluginSettings(pluginSetting: settings)
          AppManager.shared.registerPushToken()
          AppManager.shared.displayMarketingIfNeeeded()
          
          if ChannelIO.launcherWindow == nil {
            ChannelIO.launcherWindow = LauncherWindow()
          }
          
          mainStore.dispatch(ReadyToShow())
          if ChannelIO.launcherVisible {
            ChannelIO.show(animated: true)
          }
          completion?(.success, User(with: mainStore.state.user))
        }, onError: { error in
          let code = (error as NSError).code
          if code == -1001 {
            dlog("network timeout")
            mainStore.dispatch(UpdateBootState(payload: .networkTimeout))
            completion?(.networkTimeout, nil)
          } else if let error = error as? ChannelError {
            switch error {
            case .versionError:
              dlog("version is not compatiable. please update sdk version")
              mainStore.dispatch(UpdateBootState(payload: .notAvailableVersion))
              completion?(.notAvailableVersion, nil)
            case .serviceBlockedError:
              dlog("require payment. free plan is not eligible to use SDK")
              mainStore.dispatch(UpdateBootState(payload: .requirePayment))
              completion?(.requirePayment, nil)
            default:
              dlog("unknown")
              mainStore.dispatch(UpdateBootState(payload: .unknown))
              completion?(.unknown, nil)
            }
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
      AppManager.shared.registerPushToken()
    }
  }
  
  @objc
  public class func initPushToken(tokenString: String) {
    ChannelIO.pushToken = tokenString
    
    if ChannelIO.isValidStatus {
      AppManager.shared.registerPushToken()
    }
  }

  /**
   *   Shutdown ChannelIO
   *   Call this method when user terminate session or logout
   */
  @objc
  public class func shutdown() {
    AppManager.shared
      .unregisterToken()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { _ in
        dlog("shutdown success")
        ChannelIO.reset()
      }, onError: { _ in
        dlog("shutdown fail")
        ChannelIO.reset()
      }).disposed(by: self.disposeBag)
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
      ChannelIO.launcherVisible = true
            
      guard
        ChannelIO.isValidStatus,
        ChannelIO.canShowLauncher,
        ChannelIO.baseNavigation == nil else {
        return
      }
      
      let launcherView = ChannelIO.launcherView ?? LauncherView()
      
      let viewModel = LauncherViewModel(
        plugin: mainStore.state.plugin,
        user: mainStore.state.user,
        push: mainStore.state.push
      )
      
      let xMargin = ChannelIO.settings?.launcherConfig?.xMargin ?? 24
      let yMargin = ChannelIO.settings?.launcherConfig?.yMargin ?? 24
      let position = ChannelIO.settings?.launcherConfig?.position ?? .right
      
      if ChannelIO.launcherView == nil ||
        ChannelIO.launcherView?.alpha == 0 {
        if let topController = CHUtils.getTopController() {
          ChannelIO.hostTopControllerName = "\(type(of: topController))"
          ChannelIO.sendDefaultEvent(.pageView, property: [
            TargetKey.url.rawValue: "\(type(of: topController))"
          ])
        } else {
          ChannelIO.sendDefaultEvent(.pageView)
        }
      }

      launcherView.configure(viewModel)
      launcherView.buttonView
        .signalForClick()
        .subscribe(onNext: { _ in
          ChannelIO.hideNotification()
          ChannelIO.open(animated: true)
        }).disposed(by: disposeBag)
      
      if ChannelIO.launcherView == nil {
        ChannelIO.launcherWindow?.insertView(with: launcherView, animated: true)
        launcherView.alpha = 0
      }
      
      launcherView.snp.remakeConstraints { make in
        make.size.equalTo(CGSize(width:50.f, height:50.f))
        
        if position == LauncherPosition.right {
          make.right.equalToSuperview().inset(xMargin)
        } else if position == LauncherPosition.left {
          make.left.equalToSuperview().inset(xMargin)
        }
        
        if #available(iOS 11.0, *) {
          if let view = launcherView.superview {
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(yMargin)
          }
        } else {
          make.bottom.equalToSuperview().inset(yMargin)
        }
      }
      
      ChannelIO.launcherView = launcherView
      ChannelIO.launcherView?.show(animated: true)
    }
  }
  
  /**
   *  Hide channel launcher from application
   *
   *  - parameter animated: if true, the view is being removed to the window using an animation
   */
  @objc
  public class func hide(animated: Bool) {
    dispatch {
      ChannelIO.launcherView?.hide(animated: animated, completion: {
        ChannelIO.launcherVisible = false
      })
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
      guard
        ChannelIO.isValidStatus,
        !mainStore.state.uiState.isChannelVisible,
        let topController = CHUtils.getTopController() else {
        return
      }
      
      ChannelIO.launcherView?.isHidden = true
      ChannelIO.delegate?.willShowMessenger?()
      ChannelIO.hostTopControllerName = "\(type(of: topController))"
      
      mainStore.dispatch(ChatListIsVisible())
      let loungeView = LoungeRouter.createModule()
      let controller = MainNavigationController(rootViewController: loungeView)
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
    guard let topController = CHUtils.getTopController() else { return }
    
    ChannelIO.hostTopControllerName = "\(type(of: topController))"
    ChannelIO.showUserChat(userChatId: chatId, animated: animated)
  }
  
  /**
   *  Update user profile (objective-c)
   *
   *  - parameter profile: a dictionary with profile key and profile value pair. Set a value to nil
   *                       to remove existing value
   */
  @objc
  public class func updateUser(_ profile: [String: Any], completion: ((Bool, User?) -> Void)? = nil) {
    let profile:[String: Any?] = profile.mapValues { (value) -> Any? in
      return value is NSNull ? nil : value
    }
    ChannelIO.updateUser(with: profile, completion: completion)
  }
  
  @objc
  public class func updateUser(
    profile: [String: Any]? = nil,
    profileOnce: [String: Any]? = nil,
    tags: [String]? = nil,
    language: String? = nil,
    completion: ((User?, Error?) -> Void)? = nil) {
    let profile: [String: Any?]? = profile?.mapValues { (value) -> Any? in
      return value is NSNull ? nil : value
    }
    let profileOnce: [String: Any?]? = profileOnce?.mapValues { (value) -> Any? in
      return value is NSNull ? nil : value
    }
    
    ChannelIO.updateUser(
      profile: profile,
      profileOnce: profileOnce,
      tags: tags,
      language: language,
      completion: completion
    )
  }
  
  /**
   *  Update user profile
   *
   *  - parameter profile: a dictionary with profile key and profile value pair. Set a value to nil
   *                       to remove existing value
   */
  public class func updateUser(with profile: [String: Any?], completion: ((Bool, User?) -> Void)? = nil) {
    UserPromise
      .updateUser(profile: profile)
      .subscribe(onNext: { (user, error) in
        if let user = user {
          completion?(true, User(with: user))
        } else {
          completion?(false, nil)
        }
      }, onError: { error in
        completion?(false, nil)
      }).disposed(by: disposeBag)
  }
  
  public class func updateUser(
    profile: [String: Any?]? = nil,
    profileOnce: [String: Any?]? = nil,
    tags: [String]? = nil,
    language: String? = nil,
    completion: ((User?, Error?) -> Void)? = nil) {
    CHUser
      .updateUser(
        profile: profile,
        profileOnce: profileOnce,
        tags: tags,
        language: language
      )
      .subscribe(onNext: { (user, error) in
        guard let user = user else {
          completion?(nil, error)
          return
        }
        completion?(User(with: user), nil)
      }, onError: { error in
        completion?(nil, error)
      }).disposed(by: disposeBag)
   }
  
  @objc
  public class func addTags(_ tags: [String], completion: ((User?, Error?) -> Void)? = nil) {
    CHUser
      .addTags(tags: tags)
      .subscribe(onNext: { (user, error) in
        guard let user = user else {
          completion?(nil, error)
          return
        }
        completion?(User(with: user), nil)
      }, onError: { error in
        completion?(nil, error)
      }).disposed(by: disposeBag)
  }
  
  @objc
  public class func removeTags(_ tags: [String], completion: ((User?, Error?) -> Void)? = nil) {
    CHUser
      .removeTags(tags: tags)
      .subscribe(onNext: { (user, error) in
        guard let user = user else {
          completion?(nil, error)
          return
        }
        completion?(User(with: user), nil)
      }, onError: { error in
        completion?(nil, error)
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
    guard eventName.utf16.count <= 30, eventName != "" else { return }
    
    dispatch {
      dlog("[CHPlugin] Track \(eventName) property \(eventProperty ?? [:])")
      
      var property: [String: Any] = eventProperty ?? [:]
      property["pluginVersion"] = CHUtils.getSdkVersion() ?? "unknown"
      property["screenWidth"] = UIScreen.main.bounds.width
      property["screenHeight"] = UIScreen.main.bounds.height
      if property["url"] == nil, let controller = CHUtils.getTopController() {
        property["url"] = "\(type(of: controller))"
      }
      
      CHEvent.send(
        pluginId: mainStore.state.plugin.id,
        name: eventName,
        property: property)
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          dlog("Error while sending the event \(eventName). Attempting to send again")
          return true
        })
        .subscribe(onNext: { (event) in
          dlog("\(eventName) event sent successfully")
        }, onError: { (error) in
          dlog("\(eventName) event failed")
        }).disposed(by: disposeBag)
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
    let channelId = PrefStore.getCurrentChannelId() ?? ""
    
    if personType == "User" {
      return personId == userId && pushChannelId == channelId
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
    
    //NOTE: if push was received on background, just send ack to the server
    if !ChannelIO.willBecomeActive {
      AppManager.shared.sendAck(userChatId: userChatId).subscribe(onNext: { (completed) in
        completion?()
      }, onError: { (error) in
        completion?()
      }).disposed(by: self.disposeBag)
      return
    }
    
    //NOTE: handler when push was clicked by user
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
    
    if let memberId = PrefStore.getCurrentMemberId() {
      settings.memberId = memberId
    }
    
    ChannelIO.boot(with: settings, profile: profile) { (status, user) in
      if status == .success {
        ChannelIO.showUserChat(userChatId:userChatId)
      }
      completion?()
    }
  }
}
