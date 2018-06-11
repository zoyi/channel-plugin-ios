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
    ChannelIO.close(animated: true, completion: {
      let viewController = UIViewController()
      self.navigationController?.pushViewController(viewController, animated: true)
    })
    return false
  }
  
  @IBAction func onClickBoot() {
    self.pluginKeyField.resignFirstResponder()
    
    guard var pluginKey = self.pluginKeyField.text else { return }
    if pluginKey == "" {
      pluginKey = "4be44efa-59d8-4847-990f-d5cb3e9af40f" //"52eb6f27-38c7-476d-ad92-83e6299b7e07" //"06ccfc12-a9fd-4c68-b364-5d19f81a60dd"
    }
    let settings = ChannelPluginSettings(pluginKey: pluginKey)
    settings.debugMode = true

    ChannelIO.boot(with: settings) { (completion, guest) in
      
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
