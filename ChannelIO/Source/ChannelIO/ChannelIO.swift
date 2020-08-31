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
import Alamofire

internal let mainStore = Store<AppState>(
  reducer: appReducer,
  state: nil,
  middleware: [
    createMiddleware(marketingStatHook())
  ]
)

internal func dlog(_ str: String) {
  guard
    (ChannelIO.settings?.debugMode == true && !ChannelIO.isNewVersion)
      || ChannelIO.isDebugMode == true
  else {
    return
  }
  
  print("[ChannelIO]: \(str)")
}

@objc
public protocol ChannelPluginDelegate: class {
  // TODO: Will deprecated
  @available(*, deprecated, renamed: "onBadgeChanged")
  @objc optional func onChangeBadge(count: Int) -> Void /* notify badge count when changed */
  // TODO: Will deprecated
  @available(*, deprecated, renamed: "onUrlClicked")
  @objc optional func onClickChatLink(url: URL) -> Bool /* notifiy if a link is clicked */
  // TODO: Will deprecated
  @available(*, deprecated, renamed: "onShowMessenger")
  @objc optional func willShowMessenger() -> Void /* notify when chat list is about to show */
  // TODO: Will deprecated
  @available(*, deprecated, renamed: "onHideMessenger")
  @objc optional func willHideMessenger() -> Void /* notify when chat list is about to hide */
  // TODO: Will deprecated
  @available(*, deprecated, renamed: "onReceivePushData")
  @objc optional func onReceivePush(event: PushEvent) -> Void /* notifiy when new push message arrives */
  // TODO: Will deprecated
  @available(*, deprecated, renamed: "onProfileChanged")
  @objc optional func onChangeProfile(key: String, value: Any?) -> Void /* notify when the user profile has been changed */
  
  @objc optional func onShowMessenger() -> Void
  @objc optional func onHideMessenger() -> Void
  @objc optional func onChatCreated(chatId: String) -> Void
  @objc optional func onBadgeChanged(alert: Int) -> Void
  @objc optional func onProfileChanged(key: String, value: Any?) -> Void
  @objc optional func onUrlClicked(url: URL) -> Bool
  @objc optional func onPushDataReceived(event: PushData) -> Void
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

  // TODO: Will deprecated
  @available(*, deprecated, renamed: "BootConfig")
  internal static var settings: ChannelPluginSettings?
  internal static var bootConfig: BootConfig?
  // TODO: Will deprecated
  @available(*, deprecated, message: "it replaced by profile in bootConfig")
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
  
  // TODO: Will deprecated
  internal static var isNewVersion: Bool = true
  internal static var isDebugMode: Bool = false
  
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
      
      if ChannelIO.baseNavigation == nil
        && ((ChannelIO.settings?.hideDefaultInAppPush == false && !ChannelIO.isNewVersion)
          || ChannelIO.bootConfig?.hidePopup == false)
        && !push.isEqual(to: ChannelIO.lastPush) {
        ChannelIO.showNotification(pushData: push)
      }
      
      if !push.isEqual(to: ChannelIO.lastPush) {
        ChannelIO.delegate?.onReceivePush?(event: PushEvent(with: push))
        ChannelIO.delegate?.onPushDataReceived?(event: PushData(with: push))
        ChannelIO.lastPush = push
      }
    }
    
    func handleBadge(_ count: Int?) {
      guard let count = count else { return }
      
      if let curr = ChannelIO.currentAlertCount, curr != count {
        ChannelIO.delegate?.onChangeBadge?(count: count)
        ChannelIO.delegate?.onBadgeChanged?(alert: count)
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
  
  @available(iOS 13.0, *)
  @objc
  public class func initializeWindow(with scene: UIWindowScene) -> UIWindow? {
    ChannelIO.launcherWindow = LauncherWindow(windowScene: scene)
    return ChannelIO.launcherWindow
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
  // TODO: Will deprecated
  @available(*, deprecated, renamed: "boot(config:)")
  @objc
  public class func boot(
    with settings: ChannelPluginSettings,
    profile: Profile? = nil,
    completion: ((ChannelPluginCompletionStatus, User?) -> Void)? = nil
  ) {
    self.isNewVersion = false
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
        .flatMap { event in
          return ChannelIO.bootChannel(profile: profile)
        }
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { _ in
          PrefStore.setChannelPluginSettings(pluginSetting: settings)
          ChannelIO.registerPushToken()
          AppManager.shared.displayMarketingIfNeeeded()
          
          ChannelIO.launcherWindow = nil
          if #available(iOS 13.0, *) {
            if ChannelIO.launcherWindow == nil,
              let window = CHUtils
                .getWindowsOnScenes()?
                .filter({ $0 is LauncherWindow })
                .first as? LauncherWindow {
              ChannelIO.launcherWindow = window
            }
          }
          
          if ChannelIO.launcherWindow == nil {
            ChannelIO.launcherWindow = LauncherWindow()
          }
          ChannelIO.settings?.appLocale = CHUser.get().systemLanguage
          mainStore.dispatch(ReadyToShow())
          if ChannelIO.launcherVisible {
            ChannelIO.show(animated: true)
          }
          completion?(.success, User(with: mainStore.state.user))
          
          // double boot handling when sdk push click
          if let userChatId = PrefStore.getPushData()?["chatId"] as? String,
            let channelId = PrefStore.getPushData()?["channelId"] as? String,
            channelId == PrefStore.getCurrentChannelId() {
            ChannelIO.showUserChat(userChatId: userChatId)
          }
          PrefStore.clearPushData()
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
  
  @objc
  public class func boot(
    with config: BootConfig,
    completion: ((BootStatus, User?) -> Void)? = nil
  ) {
    self.isNewVersion = true
    dispatch {
      ChannelIO.bootConfig = config
      ChannelIO.deregisterPushToken()
      ChannelIO.prepare()
      
      if config.pluginKey == "" {
        mainStore.dispatch(UpdateBootState(payload: .notInitialized))
        completion?(.notInitialized, nil)
        return
      }
      
      AppManager.shared
        .checkVersion()
        .flatMap { event in
          return ChannelIO.bootChannel()
        }
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { _ in
          PrefStore.setBootConfig(bootConfig: config)
          ChannelIO.registerPushToken()
          AppManager.shared.displayMarketingIfNeeeded()
          
          if #available(iOS 13.0, *) {
            if ChannelIO.launcherWindow == nil,
              let window = CHUtils
                .getWindowsOnScenes()?
                .filter({ $0 is LauncherWindow })
                .first as? LauncherWindow {
              ChannelIO.launcherWindow = window
            }
          }
          
          if ChannelIO.launcherWindow == nil {
            ChannelIO.launcherWindow = LauncherWindow()
          }
          ChannelIO.bootConfig?.appLocale = CHUser.get().systemLanguage
          mainStore.dispatch(ReadyToShow())
          if ChannelIO.launcherVisible {
            ChannelIO.showChannelButton(animated: true)
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
  }
  
  @objc
  public class func initPushToken(tokenString: String) {
    ChannelIO.pushToken = tokenString
  }
  
  @objc
  public class func registerPushToken() {
    PrefStore.setTokenState(true)
    AppManager.shared.registerPushToken()
  }
  
  @objc
  public class func deregisterPushToken() {
    PrefStore.setTokenState(false)
    AppManager.shared
      .unregisterToken()
      .observeOn(MainScheduler.instance)
      .subscribe()
      .disposed(by: self.disposeBag)
  }
  
  @objc
  public class func setDebugMode(with debug: Bool) {
    self.isDebugMode = debug
  }

  /**
   *   Shutdown ChannelIO
   *   Call this method when user terminate session or logout
   */
  // TODO: Will deprecated
  @available(*, deprecated, renamed: "shutdown(deregisterPushToken:)")
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
  
  @objc
  public class func shutdown(deregisterPushToken: Bool) {
    if deregisterPushToken {
      AppManager.shared
        .unregisterToken()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { _ in
          dlog("shutdown success")
          PrefStore.setTokenState(false)
          ChannelIO.reset()
        }, onError: { _ in
          dlog("shutdown fail")
          PrefStore.setTokenState(false)
          ChannelIO.reset()
        }).disposed(by: self.disposeBag)
    } else {
      ChannelIO.reset()
      dlog("shutdown success")
    }
  }
    
  /**
   *   Show channel launcher on application
   *   location of the view can be customized with LauncherConfig property in ChannelPluginSettings
   *
   *   - parameter animated: if true, the view is being added to the window using an animation
   */
  // TODO: Will deprecated
  @available(*, deprecated, renamed: "showChannelButton")
  @objc
  public class func show(animated: Bool) {
    dispatch {
      ChannelIO.launcherVisible = true
            
      guard
        ChannelIO.isValidStatus,
        ChannelIO.canShowLauncher,
        ChannelIO.baseNavigation == nil
      else {
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
      
      if ChannelIO.launcherView == nil
        || ChannelIO.launcherView?.alpha == 0 {
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
  
  @objc
  public class func showChannelButton(animated: Bool) {
    dispatch {
      ChannelIO.launcherVisible = true
            
      guard
        ChannelIO.isValidStatus,
        ChannelIO.canShowLauncher,
        ChannelIO.baseNavigation == nil
      else {
        return
      }
      
      let launcherView = ChannelIO.launcherView ?? LauncherView()
      
      let viewModel = LauncherViewModel(
        plugin: mainStore.state.plugin,
        user: mainStore.state.user,
        push: mainStore.state.push
      )
      
      let xMargin = ChannelIO.bootConfig?.channelButtonOption?.xMargin ?? 24
      let yMargin = ChannelIO.bootConfig?.channelButtonOption?.yMargin ?? 24
      let position = ChannelIO.bootConfig?.channelButtonOption?.position ?? .right
      
      if ChannelIO.launcherView == nil
        || ChannelIO.launcherView?.alpha == 0 {
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
          ChannelIO.open(animated: true)
        }).disposed(by: disposeBag)
      
      if ChannelIO.launcherView == nil {
        ChannelIO.launcherWindow?.insertView(with: launcherView, animated: true)
        launcherView.alpha = 0
      }
      
      launcherView.snp.remakeConstraints { make in
        make.size.equalTo(CGSize(width:50.f, height:50.f))
        
        if position == ChannelButtonPosition.right {
          make.right.equalToSuperview().inset(xMargin)
        } else if position == ChannelButtonPosition.left {
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
  // TODO: Will deprecated
  @available(*, deprecated, renamed: "hideChannelButton")
  @objc
  public class func hide(animated: Bool) {
    dispatch {
      ChannelIO.launcherView?.hide(animated: animated, completion: {
        ChannelIO.launcherVisible = false
      })
    }
  }
  
  @objc
  public class func hideChannelButton(animated: Bool) {
    dispatch {
      ChannelIO.launcherView?.hide(animated: animated) {
        ChannelIO.launcherVisible = false
      }
    }
  }
  
  /** 
   *   Open channel messenger on application
   *
   *   - parameter animated: if true, the view is being added to the window using an animation
   */
  // TODO: Will deprecated
  @available(*, deprecated, renamed: "showMessenger")
  @objc
  public class func open(animated: Bool) {
    dispatch {
      guard
        ChannelIO.isValidStatus,
        !mainStore.state.uiState.isChannelVisible,
        let topController = CHUtils.getTopController()
      else {
        return
      }
      
      ChannelIO.hideNotification()
      ChannelIO.launcherView?.hide(animated: true)
      ChannelIO.delegate?.willShowMessenger?()
      ChannelIO.hostTopControllerName = "\(type(of: topController))"
      
      mainStore.dispatch(ChatListIsVisible())
      let loungeView = LoungeRouter.createModule()
      let controller = MainNavigationController(rootViewController: loungeView)
      ChannelIO.baseNavigation = controller
      topController.present(controller, animated: animated, completion: nil)
    }
  }
  
  @objc
  public class func showMessenger(animated: Bool) {
    dispatch {
      guard
        ChannelIO.isValidStatus,
        !mainStore.state.uiState.isChannelVisible,
        let topController = CHUtils.getTopController()
      else {
        return
      }
      
      ChannelIO.hideNotification()
      ChannelIO.launcherView?.hide(animated: true)
      ChannelIO.delegate?.onShowMessenger?()
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
  // TODO: Will deprecated
  @available(*, deprecated, renamed: "hideMessenger")
  @objc
  public class func close(animated: Bool, completion: (() -> Void)? = nil) {
    guard
      ChannelIO.isValidStatus,
      mainStore.state.uiState.isChannelVisible,
      ChannelIO.baseNavigation != nil
    else {
      completion?()
      return
    }
    
    dispatch {
      ChannelIO.delegate?.willHideMessenger?()
      ChannelIO.baseNavigation?.dismiss(animated: animated) {
        ChannelIO.didDismiss()
        completion?()
      }
    }
  }
  
  @objc
  public class func hideMessenger(animated: Bool, completion: (() -> Void)? = nil) {
    guard
      ChannelIO.isValidStatus,
      mainStore.state.uiState.isChannelVisible,
      ChannelIO.baseNavigation != nil
    else {
      completion?()
      return
    }
    
    dispatch {
      ChannelIO.delegate?.willHideMessenger?()
      ChannelIO.delegate?.onHideMessenger?()
      ChannelIO.baseNavigation?.dismiss(animated: animated) {
        ChannelIO.didDismiss()
        completion?()
      }
    }
  }
  
  /**
   *  Open a user chat with given chat id
   *
   *  - parameter chatId: a String user chat id. Will open new chat if chat id is invalid
   *  - parameter completion: a closure to signal completion state
   */
  // TODO: Will deprecated
  @available(*, deprecated, renamed: "openChat(chatId:message:animated:)")
  @objc
  public class func openChat(with chatId: String? = nil, animated: Bool) {
    guard
      ChannelIO.isValidStatus,
      let topController = CHUtils.getTopController()
    else {
      return
    }
    
    ChannelIO.hideNotification()
    ChannelIO.launcherView?.hide(animated: true)
    ChannelIO.hostTopControllerName = "\(type(of: topController))"
    ChannelIO.showUserChat(userChatId: chatId, animated: animated)
  }
  
  @objc
  public class func openChat(with chatId: String?, message: String?, animated: Bool) {
    guard
      ChannelIO.isValidStatus,
      let topController = CHUtils.getTopController()
    else {
      return
    }
    
    ChannelIO.hideNotification()
    ChannelIO.launcherView?.hide(animated: true)
    ChannelIO.hostTopControllerName = "\(type(of: topController))"
    
    if chatId.nilOrEmpty {
      ChannelIO.showUserChat(
        userChatId: chatId,
        message: message,
        isOpenChat: true,
        animated: animated
      )
    } else {
      ChannelIO.showUserChat(userChatId: chatId, animated: animated)
    }
  }
  
  /**
   *  Update user profile (objective-c)
   *
   *  - parameter profile: a dictionary with profile key and profile value pair. Set a value to nil
   *                       to remove existing value
   */
  @objc
  public class func updateUser(
    _ profile: [String: Any],
    completion: ((Bool, User?) -> Void)? = nil
  ) {
    let profile:[String: Any?] = profile.mapValues { (value) -> Any? in
      return value is NSNull ? nil : value
    }
    ChannelIO.updateUser(with: profile, completion: completion)
  }

  /**
   *  Update user profile
   *
   *  - parameter profile: a dictionary with profile key and profile value pair. Set a value to nil
   *                       to remove existing value
   */
  public class func updateUser(
    with profile: [String: Any?],
    completion: ((Bool, User?) -> Void)? = nil
  ) {
    UserPromise
      .updateUser(profile: profile)
      .subscribe(onNext: { user, error in
        if let user = user {
          completion?(true, User(with: user))
        } else {
          completion?(false, nil)
        }
      }, onError: { error in
        completion?(false, nil)
      }).disposed(by: disposeBag)
  }
  
  @objc
  public class func updateUser(
    param: UpdateUserParam,
    completion: ((User?, Error?) -> Void)? = nil) {
    CHUser
      .updateUser(param: param)
      .subscribe(onNext: { user, error in
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
      .subscribe(onNext: { user, error in
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
      .subscribe(onNext: { user, error in
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
    guard
      ChannelIO.isValidStatus,
      eventName.utf16.count <= 30,
      eventName != ""
    else {
      return
    }
    
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
        .retry(.delayed(maxCount: 3, time: 3.0)) { error in
          dlog("Error while sending the event \(eventName). Attempting to send again")
          return true
        }
        .subscribe(onNext: { event in
          dlog("\(eventName) event sent successfully")
        }, onError: { error in
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
    guard
      let provider = userInfo["provider"] as? String,
      let personType = userInfo["personType"] as? String,
      provider  == CHConstants.channelio,
      personType == PersonType.user.rawValue
    else {
      return false
    }
    
    return true
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
  // TODO: Will deprecated
  @available(*, deprecated, renamed: "receivePushNotification")
  @objc
  public class func handlePushNotification(
    _ userInfo:[AnyHashable : Any],
    completion: (() -> Void)? = nil
  ) {
    guard
      ChannelIO.isChannelPushNotification(userInfo),
      let userChatId = userInfo["chatId"] as? String
    else {
      return
    }
    
    //NOTE: if push was received on background, just send ack to the server
    AppManager.shared
      .sendAck(userChatId: userChatId)
      .subscribe()
      .disposed(by: self.disposeBag)
    
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
    
    PrefStore.setPushData(userInfo: userInfo)
    
    // boot can stop because of multiple boot
    ChannelIO.boot(with: settings, profile: profile)
    completion?()
  }
  
  @objc
  public class func receivePushNotification(
    _ userInfo:[AnyHashable : Any],
    completion: (() -> Void)? = nil
  ) {
    guard ChannelIO.isChannelPushNotification(userInfo) else { return }
    
    PrefStore.setPushData(userInfo: userInfo)
    completion?()
  }
  
  @objc
  public class func storePushNotification(_ userInfo:[AnyHashable : Any]) {
    guard
      ChannelIO.isChannelPushNotification(userInfo),
      let userChatId = userInfo["chatId"] as? String
    else {
      return
    }
    
    AppManager.shared
      .sendAck(userChatId: userChatId)
      .subscribe()
      .disposed(by: self.disposeBag)
  }
  
  @objc
  public class func hasStoredPushNotification() -> Bool {
    return PrefStore.getPushData() != nil
  }
  
  @objc
  public class func openStoredPushNotification() {
    guard
      let config = PrefStore.getBootConfig(),
      let userChatId = PrefStore.getPushData()?["chatId"] as? String,
      let channelId = PrefStore.getPushData()?["channelId"] as? String,
      channelId == PrefStore.getCurrentChannelId()
    else {
      PrefStore.clearPushData()
      return
    }
    
    if self.isBooted {
      ChannelIO.showUserChat(userChatId: userChatId)
      PrefStore.clearPushData()
    } else {
      ChannelIO.boot(with: config) { completion, user in
        ChannelIO.showUserChat(userChatId: userChatId)
        PrefStore.clearPushData()
      }
    }
  }
}
