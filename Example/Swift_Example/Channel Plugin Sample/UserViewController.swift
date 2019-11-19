//
//  LoginViewController.swift
//  Example
//
//  Created by Haeun Chung on 14/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import UIKit
import ChannelIO

class UserViewController : UIViewController {
  @IBOutlet var idField: UITextField!
  @IBOutlet var usernameField: UITextField!
  @IBOutlet var phoneField: UITextField!
  @IBOutlet var loginButton: UIButton!
  @IBOutlet var pluginKeyField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.pluginKeyField.placeholder = "Plugin Key"
    self.idField.placeholder = "user Id"
    self.usernameField.placeholder = "user name (optional)"
    self.phoneField.placeholder = "mobile number (optional)"
  }
  
  @IBAction func onClickBoot() {
    self.idField.resignFirstResponder()
    self.usernameField.resignFirstResponder()
    self.phoneField.resignFirstResponder()
    self.pluginKeyField.resignFirstResponder()
    
    guard var pluginKey = self.pluginKeyField.text else { return }
    let profile = Profile()
      .set(name: self.usernameField.text ?? "")
      .set(mobileNumber: self.phoneField.text ?? "")
    
    if pluginKey == "" {
      pluginKey = "e09962dd-4722-41c6-98d5-bd39c3a6d9eb"
    }
    
    let settings = ChannelPluginSettings(pluginKey: pluginKey)
    settings.memberId = self.idField.text
    settings.debugMode = true
    
    ChannelIO.boot(with: settings, profile: profile) { (completion, guest) in
      switch completion {
      case .success:
        break
      default:
        break
      }
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

extension UserViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.idField.resignFirstResponder()
    self.usernameField.resignFirstResponder()
    self.phoneField.resignFirstResponder()
    return true
  }
}
