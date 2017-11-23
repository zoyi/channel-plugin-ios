//
//  CHPlugin.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 10..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import CGFloatLiteral
import ManualLayout
import Reusable
import SnapKit
import Then
import ReSwift
import RxSwift
import UIColor_Hex_Swift
import UserNotifications
import SVProgressHUD
import CRToast
import AVFoundation


let mainStore = Store<AppState>(
  reducer: appReducer,
  state: nil,
  middleware: [loggingMiddleware]
)

func dlog(_ str: String) {
  guard ChannelPlugin.debugMode else { return }
  print("[CHPlugin]: \(str)")
}

@objc
public protocol ChannelDelegate: class {
  @objc optional func badgeDidChange(count: Int) -> Void /* notify badge count when changed */
  @objc optional func shouldHandleChatLink(url: URL) -> Bool /* notifiy if a link is clicked */
  @objc optional func willShowChatList() -> Void /* notify when chat list is about to show */
  @objc optional func willHideChatList() -> Void /* notify when chat list is about to hide */ 
}

@objc
public final class ChannelPlugin : NSObject {
  public static weak var delegate: ChannelDelegate? = nil
  
  private static var pluginId: String?
  private static var launchView : LaunchView?
  private static var chatNotificationView: ChatNotificationView?
  private static var baseNavigation: BaseNavigationController?
  private static var subscriber : CHPluginSubscriber!

  private static var disposeBeg = DisposeBag()
  private static var pushToken: String?
  private static var currentAlertCount = 0
  fileprivate static var isCheckedIn: Bool = false

  private static let toastOptions:[AnyHashable: Any] = [
    kCRToastNotificationPresentationTypeKey: CRToastPresentationType.cover.rawValue,
    kCRToastNotificationTypeKey: CRToastType.navigationBar.rawValue,
    kCRToastAnimationInDirectionKey: CRToastAnimationDirection.top.rawValue,
    kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.top.rawValue,
    kCRToastBackgroundColorKey: CHColors.yellow,
    kCRToastTextColorKey: UIColor.white,
    kCRToastFontKey: UIFont.boldSystemFont(ofSize: 13)
  ]
  
  //set debug mode of channel
  @objc public static var debugMode = false
  //set launcher show automatically when checkin succeed
  @objc public static var hideLauncherButton = false
  //set default checkin tracking
  @objc public static var enabledTrackDefaultEvent = true
  
  // MARK: StoreSubscriber

  class CHPluginSubscriber : StoreSubscriber {
    func newState(state: AppState) {
      
      self.handleBadgeDelegate(state.guest.alert)
      
      if let launchView = ChannelPlugin.launchView {
        let viewModel = LaunchViewModel(
          plugin: state.plugin, guest: state.guest
        )
        launchView.configure(viewModel)
      }
      
      self.handlePush(push: state.push)
    }
    
    func handlePush (push: CHPush?) {
      if ChannelPlugin.baseNavigation == nil {
        ChannelPlugin.showNotification(pushData: push)
      }
    }
    
    func handleBadgeDelegate(_ count: Int) {
      if ChannelPlugin.currentAlertCount != count {
        ChannelPlugin.delegate?.badgeDidChange?(count: count)
      }
      ChannelPlugin.currentAlertCount = count
    }
  }
  
  // MARK: Public

  /**
   *   Initalize channel plugin.
   *   This method has to be called prior to any other methods
   *   provided by channel plugin
   *
   *   - parameter pluginId: plugin key from Channel io
   */
  @objc public class func initialize(pluginId: String) {
    ChannelPlugin.initWebsocket()
    ChannelPlugin.pluginId = pluginId
    ChannelPlugin.subscriber = CHPluginSubscriber()
    mainStore.subscribe(ChannelPlugin.subscriber)
    CRToastManager.setDefaultOptions(toastOptions)

    // Init other frameworks
    SVProgressHUD.setDefaultStyle(.dark)
    
    UtilityPromise.getCountryCodes()
      .subscribe(onNext:{ (countries) in
        mainStore.dispatch(GetCountryCodes(payload: countries))
      }).disposed(by: disposeBeg)
  }

  /**
   *    Register a push token.
   *   This method has to be called within
   *   `application:didRegisterForRemoteNotificationsWithDeviceToken:`
   *   in `AppDelegate` in order to get receive push notification from Channel io
   *
   *   - parameter token: a Data that represents device token
   */
  @objc public class func register(deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    self.pushToken = token
  }

  /**
   *   Check in channel io
   *   Call this method first in order to start using any chatting feature
   *
   *   - parameters:
   *     - checkinObj: Checkin object contains necessary information
   *     - completion: Completion callback block
   *
   */
  @objc public class func checkIn(_ checkinObj: CheckIn? = nil,
            completion: ((ChannelCheckInCompletionStatus) -> Void)? = nil) {
    if ChannelPlugin.pluginId == nil || ChannelPlugin.pluginId == "" {
      mainStore.dispatch(UpdateCheckinState(payload: .notInitialized))
      completion?(.notInitialized)
      return
    }
    
    if mainStore.state.guest.id != "" {
      mainStore.dispatch(UpdateCheckinState(payload: .duplicated))
      completion?(.duplicated)
      return
    }
    
    let topController = CHUtils.getTopController()
    
    PluginPromise.checkVersion()
      .flatMap { (event) -> Observable<Any?> in
      return checkInChannel(checkinObj: checkinObj)
    }.subscribe(onNext: { (event) in
      mainStore.dispatch(UpdateCheckinState(payload: .success))
      completion?(.success)
      
      if !ChannelPlugin.hideLauncherButton &&
        !mainStore.state.plugin.mobileHideButton {
        ChannelPlugin.showLauncher(
          on: topController?.view,
          animated: true)
      }
      ChannelPlugin.fetchScripts()
      ChannelPlugin.registerPushToken()
    }, onError: { error in
      dlog("Check in error: \(error)")
      let code = (error as NSError).code
      if code == -1001 {
        mainStore.dispatch(UpdateCheckinState(payload: .networkTimeout))
        completion?(.networkTimeout)
      } else if code == CHErrorCode.versionError.rawValue {
        mainStore.dispatch(UpdateCheckinState(payload: .notAvailableVersion))
        completion?(.notAvailableVersion)
      } else if code == CHErrorCode.serviceBlockedError.rawValue {
        mainStore.dispatch(UpdateCheckinState(payload: .requirePayment))
        completion?(.requirePayment)
      } else {
        mainStore.dispatch(UpdateCheckinState(payload: .checkinError))
        completion?(.checkinError)
      }
    }).disposed(by: disposeBeg)
  }
  
  /**
   *   Check out from channel
   *   Call this method when user terminate session or logout
   */
  @objc public class func checkOut() {
    ChannelPlugin.hideLauncher(animated: false)
    ChannelPlugin.hide(animated: false)
    ChannelPlugin.hideNotification()
    
    PluginPromise.unregisterPushToken()
      .subscribe(onNext: { _ in
        dlog("[CHPlugin] : Checkout success")
      }, onError: { (error) in
        
      }).disposed(by: disposeBeg)
    
    WsService.shared.disconnect()
    mainStore.dispatch(CheckOutSuccess())
    ChannelPlugin.isCheckedIn = false
  }
  
  /**
   *   Show channel launcher view on application
   *   location of the view can be customized in Channel Desk
   *
   *   - parameter animated: if true, the view is being added to the window using an animation
   */
  @objc public class func showLauncher(animated: Bool) {
    guard let topController = CHUtils.getTopController() else {
      return
    }
    ChannelPlugin.showLauncher(on: topController.view, animated: animated)
  }
  
  /**
   *   Show channel launcher view on a specific view
   *
   *   - parameter on: view where laucher will be displayed
   *   - parameter animated: if true, the view is being added to the window using an animation
   */
  private class func showLauncher(on view:UIView?, animated: Bool) {
    guard let view = view else { return }
    
    let checkinStatus = mainStore.state.checkinState.status
    if checkinStatus != .success &&
       checkinStatus != .duplicated {
      return
    }
    
    ChannelPlugin.hideLauncher(animated: false)
    
    let launchView = LaunchView()
    let viewModel = LaunchViewModel(
      plugin: mainStore.state.plugin, guest: mainStore.state.guest
    )
    
    launchView.show(onView: view, animated: animated)
    launchView.configure(viewModel)
    
    launchView.buttonView.signalForClick()
      .subscribe(onNext: { _ in
        ChannelPlugin.show(animated: true)
      }).disposed(by: disposeBeg)
    
    ChannelPlugin.launchView = launchView
  }
  
  /**
   *  Hide channel launcher view from application
   *
   *  - parameter animated: if true, the view is being added to the window using an animation
   */
  @objc public class func hideLauncher(animated: Bool) {
    guard (ChannelPlugin.launchView != nil) else { return }
    
    ChannelPlugin.launchView?.remove(animated: animated)
    ChannelPlugin.launchView = nil
  }
  
  /** 
   *   Show channel messenger on application
   *
   *   - parameter animated: if true, the view is being added to the window using an animation
   */
  @objc public class func show(animated: Bool) {
    guard let topController = CHUtils.getTopController() else {
      return
    }
    
    let checkinStatus = mainStore.state.checkinState.status
    if checkinStatus != .success &&
      checkinStatus != .duplicated  {
      return
    }
    
    if mainStore.state.uiState.isChannelVisible {
      return
    }
    
    ChannelPlugin.delegate?.willShowChatList?()
    mainStore.dispatch(ChannelIsShown())

    let controller = MainNavigationController(rootViewController: UserChatsViewController())
    ChannelPlugin.baseNavigation = controller
    topController.present(controller, animated: animated, completion: nil)
  }

  /**
   *   Hide channel messenger from application
   *
   *   - parameter animated: if true, the view is being added to the window using an animation
   */
  @objc public class func hide(animated: Bool) {
    guard ChannelPlugin.baseNavigation != nil else { return }
    ChannelPlugin.delegate?.willHideChatList?()
    ChannelPlugin.baseNavigation?.dismiss(
      animated: animated, completion: {
      mainStore.dispatch(ChannelIsHidden())

      ChannelPlugin.baseNavigation?.removeFromParentViewController()
      ChannelPlugin.baseNavigation = nil
    })
  }
  
  /**
   *   Check whether push notification is valid Channel push notification
   *   by inspecting userInfo
   *
   *   - parameter userInfo: a Dictionary contains push information
   */
  @objc public class func isChannelPushNotification(_ userInfo:[AnyHashable: Any]) -> Bool {
    guard let provider = userInfo["provider"] else { return false }
    let isCorrectProvider = provider as! String == CHConstants.channelio
    
    let userId = PrefStore.getCurrentUserId() ?? ""
    let veilId = PrefStore.getCurrentVeilId() ?? ""
    let channelId = PrefStore.getCurrentChannelId() ?? ""
    
    let personType = userInfo["personType"] as! String
    let personId = userInfo["personId"] as! String
    let pushChannelId = userInfo["channelId"] as! String
    
    if personType == "User" {
      return personId == userId && pushChannelId == channelId && isCorrectProvider
    }
    
    if personType == "Veil" {
      return personId == veilId && pushChannelId == channelId && isCorrectProvider
    }
    
    return false
  }
  
  
  /**
   *  Track a event
   *
   *   - parameter name: Event name
   *   - parameter userInfo: a Dictionary contains information about event
   */
  @objc public class func track(name: String, properties: [String: Any]? = nil) {
    let version = Bundle(for: ChannelPlugin.self)
      .infoDictionary?["CFBundleShortVersionString"] as! String
    
    ChannelPlugin.track(name: name, properties: properties, sysProperties: [
      "pluginId": pluginId!,
      "pluginVersion": version,
      "device": UIDevice.current.modelName,
      "os": "\(UIDevice.current.systemName)_\(UIDevice.current.systemVersion)",
      "screenWidth": UIScreen.main.bounds.width,
      "screenHeight": UIScreen.main.bounds.height
    ])
  }
  
  /**
   *   Handle push notification for channel
   *   This method has to be called within `userNotificationCenter:response:completionHandler:`
   *   for **iOS 10 and above**, and `application:userInfo:completionHandler:`
   *   for **other version of iOS** in `AppDelegate` in order to make channel
   *   plugin worked properly
   *
   *   - parameter userInfo: a Dictionary contains push information
   */
  @objc public class func handlePushNotification(_ userInfo:[AnyHashable : Any]) {
    if !ChannelPlugin.isChannelPushNotification(userInfo) {
      return
    }

    //check if checkin 
    if mainStore.state.channel.id != "" {
      let userChatId = userInfo["chatId"] as! String
      ChannelPlugin.showUserChat(userChatId:userChatId)
      return
    }
    
    let checkin = CheckIn()
      .with(userId: PrefStore.getCurrentUserId() ?? "")
    checkInChannel(checkinObj:checkin)
      .subscribe(onNext: { (result) in
      let userChatId = userInfo["chatId"] as! String
      ChannelPlugin.fetchScripts()
      ChannelPlugin.registerPushToken()
      //not guarantee to be connected here
      ChannelPlugin.showUserChat(userChatId:userChatId)
    }).disposed(by: disposeBeg)
  }

  
  // MARK: Helper methods
  private class func track(
    name: String,
    properties: [String: Any]? = nil,
    sysProperties: [String: Any]?) {
    if name.utf16.count > 30 || name == "" {
      return
    }
    
    EventPromise.sendEvent(
      name: name,
      properties: properties,
      sysProperties: sysProperties)
      .subscribe(onNext: { (event) in
        
      }, onError: { (error) in
        
      }).disposed(by: disposeBeg)
  }
  
  private class func checkInChannel(checkinObj: CheckIn? = nil) -> Observable<Any?> {
    return Observable.create { subscriber in
      
      guard pluginId != nil else {
        dlog("You should set plugin key before check in.")
        return Disposables.create()
      }
      
      //already loaded up
      if mainStore.state.guest.id != "" {
        subscriber.onNext(nil)
        subscriber.onCompleted()
        return Disposables.create()
      }
      
      var params = [String: Any]()
      if let checkin = checkinObj {
        params["body"] = checkin.generateParams()
      }
      
      if checkinObj?.userId != "" {
        PrefStore.setCurrentUserId(userId: checkinObj?.userId)
      } else {
        PrefStore.clearCurrentUserId()
      }

      PluginPromise
        .getPluginConfiguration(apiKey: pluginId!, params: params)
        .subscribe(onNext: { (data) in
          let channel = data["channel"] as! CHChannel
          if channel.isBlocked() {
            subscriber.onError(CHErrorPool.serviceBlockedError)
            return
          }
          
          WsService.shared.connect()
          mainStore.dispatch(CheckInSuccess(payload: data))
          ChannelPlugin.isCheckedIn = true
          
          if ChannelPlugin.enabledTrackDefaultEvent {
            ChannelPlugin.track(name: "Checkin", properties: nil)
          }
          
          WsService.shared.ready()
            .subscribe(onNext: { _ in
              subscriber.onNext(data)
              subscriber.onCompleted()
          }).disposed(by: disposeBeg)
          
        }, onError: { error in
          subscriber.onError(error)
        }, onCompleted: {
          dlog("Check in complete")
        }).disposed(by: disposeBeg)
      
      return Disposables.create()
    }
  }
  
  private class func showUserChat(userChatId: String?) {
    guard let userChatId = userChatId else { return }
    guard let topController = CHUtils.getTopController() else {
      return
    }

    let userChatController = UserChatViewController()
    userChatController.userChatId = userChatId
   
    mainStore.dispatch(ChannelIsShown())

    if let userChatViewController = topController as? UserChatViewController,
      userChatViewController.userChatId == userChatId {
      //do nothing
    }
    else if topController is UserChatsViewController ||
      topController is UserChatViewController {
      topController.navigationController?.pushViewController(userChatController, animated: true)
    } else {
      let userChatsController = UserChatsViewController()
      let controller = MainNavigationController(rootViewController: userChatsController)
      ChannelPlugin.baseNavigation = controller
      
      userChatsController.signalForLoaded().subscribe(onNext: { _ in
         controller.pushViewController(userChatController, animated: true)
      }).disposed(by: disposeBeg)
      topController.present(controller, animated: false, completion:nil)
    }
    
  }
  
  private class func registerPushToken() {
    guard let pushToken = self.pushToken else { return }
    
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
  
  private class func showNotification(pushData: CHPush?) {
    guard let topController = CHUtils.getTopController(),
          let push = pushData else {
      return
    }

    ChannelPlugin.hideNotification()
    
    let notificationView = ChatNotificationView()
    notificationView.topLayoutGuide = topController.topLayoutGuide
    
    let notificationViewModel = ChatNotificationViewModel(push: push)
    notificationView.configure(notificationViewModel)
    notificationView.show(onView: topController.view, animated: true)
    
    notificationView.signalForClick()
      .subscribe(onNext: { (event) in
        ChannelPlugin.hideNotification()
        ChannelPlugin.showUserChat(userChatId: push.userChat?.id)
      }).disposed(by: disposeBeg)
    
    notificationView.closeView.signalForClick()
      .subscribe { (event) in
        ChannelPlugin.hideNotification()
      }.disposed(by: disposeBeg)
    
    ChannelPlugin.chatNotificationView = notificationView
   
    // create a sound ID, in this case its the tweet sound.
    // to play sound  
    if PrefStore.getPushSoundOption() {
      CHAssets.playPushSound()
    }

    mainStore.dispatch(RemovePush())
  }
  
  private class func hideNotification() {
    guard ChannelPlugin.chatNotificationView != nil else {
      return
    }
    mainStore.dispatch(RemovePush())
    ChannelPlugin.chatNotificationView?.remove(animated: true)
    ChannelPlugin.chatNotificationView = nil
  }

  private class func fetchScripts() {
    ScriptPromise
      .get(pluginId: mainStore.state.plugin.id)
      .subscribe(onNext: { (scripts) in
        mainStore.dispatch(GetScripts(payload: scripts))
      }, onError:{ error in
        // no action
      }).disposed(by: disposeBeg)
  }
  
  @objc class func appBecomeActive(_ application: UIApplication) {
    guard ChannelPlugin.isCheckedIn == true else {
      return
    }
    _ = GuestPromise.getCurrent().subscribe(onNext: { (user) in
      mainStore.dispatch(UpdateGuest(payload: user))
    })
  }

}

extension ChannelPlugin {
  fileprivate class func initWebsocket() {
    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(ChannelPlugin.disconnectWebsocket),
        name: NSNotification.Name.UIApplicationWillResignActive,
        object: nil)
    
    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(ChannelPlugin.disconnectWebsocket),
        name: NSNotification.Name.UIApplicationWillTerminate,
        object: nil)
    
    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(ChannelPlugin.connectWebsocket),
        name: NSNotification.Name.UIApplicationDidBecomeActive,
        object: nil)
    
    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(ChannelPlugin.appBecomeActive(_:)),
        name: Notification.Name.UIApplicationWillEnterForeground,
        object: nil)
  }
  
  @objc private class func disconnectWebsocket() {
    WsService.shared.disconnect()
  }
  
  @objc private class func connectWebsocket() {
    guard ChannelPlugin.isCheckedIn == true else {
      return
    }
    WsService.shared.connect()
  }
}
