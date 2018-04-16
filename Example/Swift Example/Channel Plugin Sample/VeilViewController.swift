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
    
    if self.isMovingFromParentViewController {
      ChannelIO.shutdown()
    }
  }
  
  func willOpenMessenger() {
    print("will show")
  }
  
  func willCloseMessenger() {
    print("will hide")
  }
  
  func onClickChatLink(url: URL) -> Bool {
    return true
  }
  
  @IBAction func onClickBoot() {
    self.pluginKeyField.resignFirstResponder()
    
    guard var pluginKey = self.pluginKeyField.text else { return }
    pluginKey = "370872b2-1299-48de-b020-16845bcc5d9f"
    let settings = ChannelPluginSettings(pluginKey: pluginKey)
    settings.debugMode = true
    ChannelIO.boot(with: settings) { completion in
      
    }
  }

  @IBAction func onClickShutdown() {
    ChannelIO.shutdown()
  }
  
  @IBAction func onClickShowChat(_ sender: Any) {
    ChannelIO.open(animated: true)
  }
  
  @IBAction func onClickShowLauncher(_ sender: Any) {
    ChannelIO.show(animated: true)
  }
  
  @IBAction func onClickHideLauncher(_ sender: Any) {
    ChannelIO.hide(animated: true)
  }
}
