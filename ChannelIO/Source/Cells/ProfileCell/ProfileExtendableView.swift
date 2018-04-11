//
//  ProfileExtendableView.swift
//  ChannelIO
//
//  Created by R3alFr3e on 4/11/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit

class ProfileExtendableView: BaseView {
  var items: [ProfileContentProtocol] = []
  
  override func initialize() {
    super.initialize()
  }
  
  override func setLayouts() {
    super.setLayouts()
  }
  
  func configure(model: ProfileCellModelType) {
    //looop items
      //if filled display
      //not filled break and display
  }
  
  class func viewHeight(model: ProfileCellModelType) -> CGFloat {
    //if first then check footer?
    //calculate completed fields * 80
    return 0.0 
  }
}
