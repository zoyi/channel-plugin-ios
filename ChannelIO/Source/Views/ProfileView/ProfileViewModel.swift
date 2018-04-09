//
//  ProfileViewModel.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 13..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation

protocol ProfileViewModelType {
  var cells: [(String, String?)] { get }
}

struct ProfileViewModel: ProfileViewModelType {
  var cells: [(String, String?)]

  init(guest: CHGuest?) {

    self.cells = []

    guard guest != nil else { return }

    if guest?.name != nil && guest?.ghost == false {
      self.cells.append((CHAssets.localized("ch.user_profile.user_name"), guest?.name))
    }
    if guest?.mobileNumber != nil {
      self.cells.append((CHAssets.localized("ch.user_profile.mobile_number"), guest?.mobileNumber))
    }
    if self.cells.count == 0 {
      self.cells.append((CHAssets.localized("ch.user_profile.empty"), nil))
    }
  }
}
