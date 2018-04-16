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
    
    self.layer.borderColor = CHColors.dark10.cgColor
    self.layer.borderWidth = 1.f
    self.layer.cornerRadius = 6.f
    
    self.layer.shadowColor = CHColors.dark10.cgColor
    self.layer.shadowOpacity = 0.2
    self.layer.shadowOffset = CGSize(width: 0, height: 2)
    self.layer.shadowRadius = 3
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
