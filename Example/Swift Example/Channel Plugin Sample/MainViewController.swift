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

class MainViewController : UIViewController, ChannelIODelegate {
  @IBOutlet var loginTypeLabel: UILabel!
  @IBOutlet var descLabel: UILabel!
  
  var loaded: Bool = false
  var isUser: Bool = false
  var userId: String = ""
  var userName: String = ""
  var phoneNumber: String = ""
  override func viewDidLoad() {
    super.viewDidLoad()
    ChannelIO.delegate = self
    self.loginTypeLabel.text = self.isUser
      ? "Checked in (user)" : "Checked in (veil)"
    self.descLabel.text = "Check out when navigates back"
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if self.loaded == false {
      self.isUser ? self.loginAsUser() : self.loginAsVeil()
      self.loaded = true
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if self.isMovingFromParentViewController {
      ChannelIO.shutdown()
    }
  }
  
  func willShowChatList() {
    print("will show")
  }
  
  func willHideChatList() {
    print("will hide")
  }
  
  func onClickChatLink(url: URL) -> Bool {
    return true
  }
  
  func loginAsUser() {
    if self.userId == "" {
      return
    }
    
    let guest = Guest()
      .set(name: self.userName)
      .set(id: self.userId)
      .set(mobileNumber: self.phoneNumber)
    
    let settings = ChannelPluginSettings(pluginKey: "52eb6f27-38c7-476d-ad92-83e6299b7e07")
    
    ChannelIO.boot(with: settings, guest: guest) { (completion) in
      switch completion {
      case .success:
        break
      default:
        self.loginTypeLabel.text = "Login failed due to invalid parameters"
        self.descLabel.text = "Please go back and try again"
      }
    }
  }
  
  func loginAsVeil() {
    let settings = ChannelPluginSettings(pluginKey: "52eb6f27-38c7-476d-ad92-83e6299b7e07")
    
    ChannelIO.boot(with: settings) { completion in
      
    }
  }
}
