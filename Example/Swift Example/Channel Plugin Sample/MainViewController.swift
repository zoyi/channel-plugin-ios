//
//  MainViewController.swift
//  Example
//
//  Created by Haeun Chung on 14/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import UIKit
import CHPlugin

class MainViewController : UIViewController, ChannelDelegate {
  @IBOutlet var loginTypeLabel: UILabel!
  @IBOutlet var descLabel: UILabel!
  
  var loaded: Bool = false
  var isUser: Bool = false
  var userId: String = ""
  var userName: String = ""
  var phoneNumber: String = ""
  override func viewDidLoad() {
    super.viewDidLoad()
    ChannelPlugin.delegate = self
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
      ChannelPlugin.checkOut()
    }
  }
  
  func shouldHandleChatLink(url: URL) -> Bool {
    return true
  }
  
  func loginAsUser() {
    if self.userId == "" {
      return
    }
    
    let checkin = CheckIn()
    checkin.with(name: self.userName)
      .with(userId: self.userId)
      .with(mobileNumber: self.phoneNumber)
    
    ChannelPlugin.checkIn(checkin) { completion in
      //compltion block
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
    
    ChannelPlugin.checkIn { completion in
      //compltion block

    }
  }
}
