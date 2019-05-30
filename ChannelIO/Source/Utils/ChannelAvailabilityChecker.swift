//
//  ChannelAvailabilityChecker.swift
//  ChannelIO
//
//  Created by Haeun Chung on 20/05/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ChannelAvailabilityChecker {
  static var shared = ChannelAvailabilityChecker()
  
  var timer: Timer?
  var updateSignal = PublishRelay<Any?>()
  
  private init() {}
  
  func run() {
    self.timer?.invalidate()
    self.timer = Timer.scheduledTimer(
      timeInterval: 20.0,
      target: self,
      selector: #selector(checkAvailability),
      userInfo: nil,
      repeats: true)
  }
  
  func stop() {
    self.timer?.invalidate()
  }
  
  @objc func checkAvailability() {
    let channel = mainStore.state.channel
    let currentTime = Date()
    
    guard channel.workingType == .custom else { return }
    guard let (nextOpTime, _) = channel.closestWorkingTime(from: currentTime) else { return }

    if nextOpTime > currentTime {
      self.updateSignal.accept(nil)
    }
  }
}

