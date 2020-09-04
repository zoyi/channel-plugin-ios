//
//  MainViewController.swift
//  Example
//
//  Created by Haeun Chung on 14/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import UIKit
import ChannelIO

class VeilViewController : UIViewController, ChannelPluginDelegate {
  @IBOutlet var pluginKeyField: UITextField!
  
  @IBOutlet var customPushView: UIView!
  @IBOutlet var avatarView: UIImageView!
  @IBOutlet var pushMessageLabel: UILabel!
  
  var chatId: String? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.pluginKeyField.placeholder = "Plugin Key"
    ChannelIO.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if self.isMovingFromParent {
      ChannelIO.shutdown()
    }
  }
  
  func onClickChatLink(url: URL) -> Bool {
    print("url 1")
    print(url.absoluteString)
    return false
  }
  
  func onUrlClicked(url: URL) -> Bool {
    print("url 2")
    print(url.absoluteString)
    return false
  }
  
  func onChangeProfile(key: String, value: Any?) {
    print("profile 1")
    print("\(key) is \(value)")
  }
  
  func onProfileChanged(key: String, value: Any?) {
    print("profile 2")
    print("\(key) is \(value)")
  }
  
  func onShowMessenger() {
    print("on show")
  }
  
  func willShowMessenger() {
    print("will show")
  }
  
  func onHideMessenger() {
    print("on hide")
  }
  
  func onChatCreated(chatId: String) {
    print("create chat : \(chatId)")
  }
  
  func willHideMessenger() {
    print("will hide")
  }
  
  func onReceivePush(event: PushEvent) {
    print("event 1: ")
    print(event.toJson())
  }
  
  func onPopupDataReceived(event: PopupData) {
    print("event 2: ")
    print(event.toJson())
  }
  
  func onChangeBadge(count: Int) {
    print("badge called \(count)")
  }
  
  func onBadgeChanged(alert: Int) {
    print("badge called \(alert)")
  }
  
  @objc func didClickOnPush() {
    if let chatId = self.chatId {
      ChannelIO.openChat(with: chatId, message: nil)
    }
  }
  
//  func onClickChatLink(url: URL) -> Bool {
//    ChannelIO.close(animated: true, completion: {
//      let viewController = UIViewController()
//      self.navigationController?.pushViewController(viewController, animated: true)
//    })
//    return false
//  }
  
  @IBAction func onClickBoot() {
    self.pluginKeyField.resignFirstResponder()
    
    guard var pluginKey = self.pluginKeyField.text else { return }
    if pluginKey == "" {
      pluginKey = "d788f832-1e59-457c-a3ed-32ac8200bec1"
    }
//    let settings = ChannelPluginSettings(pluginKey: pluginKey)
//    settings.debugMode = true
    let bootConfig = BootConfig(pluginKey: pluginKey)
    bootConfig.stage = .development
//    bootConfig.hidePopup = true
//    bootConfig.trackDefaultEvent = false
//    bootConfig.language = .english
//    bootConfig.set(unsubscribed: true)
//    settings.stage = .development
//    settings.launcherConfig = LauncherConfig(
//      position: .left, xMargin: 100, yMargin: 200
//    )
    
    let profile = Profile()
    profile.set(name: "TESTER")
    bootConfig.profile = profile
    ChannelIO.setDebugMode(with: true)
    ChannelIO.boot(with: bootConfig) { (completion, user) in
//      ChannelIO.openChat(with: "5f51c00bca88425e6d72123123", message: nil)
    }
//    ChannelIO.boot(with: settings, profile: profile) { (completion, user) in
//
//    }
  }

  @IBAction func onClickShutdown() {
    ChannelIO.shutdown()
  }
  
  @IBAction func onClickShowChat(_ sender: Any) {
    ChannelIO.track(eventName: "PageView", eventProperty: ["url":"Main"])
    //ChannelIO.open(animated: true)
  }
  
  @IBAction func onClickShowLauncher(_ sender: Any) {
    ChannelIO.showChannelButton()
  }
  
  @IBAction func onClickHideLauncher(_ sender: Any) {
    ChannelIO.hideChannelButton()
  }
}
