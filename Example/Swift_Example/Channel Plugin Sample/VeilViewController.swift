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
      ChannelIO.shutdown(deregisterPushToken: false)
    }
  }
  
  func willShowMessenger() {
    print("will show")
  }
  
  func willHideMessenger() {
    print("will hide")
  }
  
  func onReceivePushData(event: PushData) {
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
      ChannelIO.openChat(with: chatId, message: nil, animated: true)
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
//    settings.stage = .development
//    settings.launcherConfig = LauncherConfig(
//      position: .left, xMargin: 100, yMargin: 200
//    )
    
    let profile = Profile()
    profile.set(name: "TESTER")
    bootConfig.profile = profile
    ChannelIO.setDebugMode(with: true)
    ChannelIO.boot(with: bootConfig) { (completion, user) in
//      ChannelIO.openChat(with: nil, message: nil, animated: true)
    }
//    ChannelIO.boot(with: settings, profile: profile) { (completion, user) in
//
//    }
  }

  @IBAction func onClickShutdown() {
    ChannelIO.shutdown(deregisterPushToken: true)
  }
  
  @IBAction func onClickShowChat(_ sender: Any) {
    ChannelIO.track(eventName: "PageView", eventProperty: ["url":"Main"])
    //ChannelIO.open(animated: true)
  }
  
  @IBAction func onClickShowLauncher(_ sender: Any) {
    ChannelIO.showChannelButton(animated: true)
  }
  
  @IBAction func onClickHideLauncher(_ sender: Any) {
    ChannelIO.hideChannelButton(animated: true)
  }
}
