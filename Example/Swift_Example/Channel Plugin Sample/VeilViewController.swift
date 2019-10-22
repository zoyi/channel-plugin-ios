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
  
  func willShowMessenger() {
    print("will show")
  }
  
  func willHideMessenger() {
    print("will hide")
  }
  
  func onReceivePush(event: PushEvent) {
//    self.customPushView.isHidden = false
//    self.avatarView.sd_setImage(with: URL(string: event.senderAvatarUrl)!)
//    self.pushMessageLabel.text  = event.message
//    self.chatId = event.chatId
//
//    let gesture = UITapGestureRecognizer(target: self, action: #selector(didClickOnPush))
//    gesture.numberOfTapsRequired = 1
//    self.customPushView.addGestureRecognizer(gesture)
  }
  
  func onChangeBadge(count: Int) {
    print("badge called \(count)")
  }
  
  @objc func didClickOnPush() {
    if let chatId = self.chatId {
      ChannelIO.openChat(with: chatId, animated: true)
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
      pluginKey = "98855048-7a98-45b4-bf91-026bda7691ce"
    }
    let settings = ChannelPluginSettings(pluginKey: pluginKey)
    settings.debugMode = true
//    settings.launcherConfig = LauncherConfig(
//      position: .left, xMargin: 100, yMargin: 200
//    )
    
    let profile = Profile()
    profile.set(propertyKey: "Coin", value: 212)
    profile.set(propertyKey: "age", value:1231231)
    profile.set(name: "TESTER")
    ChannelIO.boot(with: settings, profile: profile) { (completion, guest) in
      
    }
  }

  @IBAction func onClickShutdown() {
    ChannelIO.shutdown()
  }
  
  @IBAction func onClickShowChat(_ sender: Any) {
    ChannelIO.track(eventName: "pageView", eventProperty: ["url":"Main"])
    //ChannelIO.open(animated: true)
  }
  
  @IBAction func onClickShowLauncher(_ sender: Any) {
    ChannelIO.show(animated: true)
  }
  
  @IBAction func onClickHideLauncher(_ sender: Any) {
    ChannelIO.hide(animated: true)
  }
}
