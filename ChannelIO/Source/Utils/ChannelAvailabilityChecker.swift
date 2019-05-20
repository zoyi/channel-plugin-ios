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
    print("availability run!")
    self.timer?.invalidate()
    self.timer = Timer.scheduledTimer(
      timeInterval: 10.0,
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
    
    let nextOpTime = channel.closestWorkingTime(from: currentTime)
    print("checker running..")
    //is in working time but channel working is false
    if nextOpTime?.timeLeft == 0 && !channel.working {
      print("availability: in to out")
      self.updateSignal.accept(nil)
    }
    //is not in working time but channel working is true
    else if nextOpTime?.timeLeft != 0 && channel.working {
      print("availability: out to in")
      self.updateSignal.accept(nil)
    }
  }
}

