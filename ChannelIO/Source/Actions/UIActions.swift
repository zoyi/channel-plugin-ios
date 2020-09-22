//
//  UIActions.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 13..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

struct ShowProfile: ReSwift_Action {}

struct HideProfile: ReSwift_Action {}

struct ChatListIsVisible: ReSwift_Action {}

struct ChatListIsHidden: ReSwift_Action {}

// boot state

struct UpdateBootState: ReSwift_Action {
  public let payload: BootStatus
}

struct ReadyToShow: ReSwift_Action {}
