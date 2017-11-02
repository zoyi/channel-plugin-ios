//
//  UserInfoGuideCell.swift
//  CHPlugin
//
//  Created by Haeun Chung on 23/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Reusable
import SwiftDate
import SnapKit

final class UserInfoDialogCell : BaseTableViewCell, Reusable {
  let dialogView = DialogView()
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.dialogView)
    
    self.dialogView.snp.remakeConstraints { (make) in
      make.top.equalToSuperview().inset(10)
      make.leading.equalToSuperview().inset(10)
      make.trailing.equalToSuperview().inset(10)
      make.bottom.equalToSuperview().inset(10)
    }
  }
  
  func configure(viewModel: DialogViewModelType) {
    self.dialogView.configure(viewModel: viewModel)
  }
  
  class func measureHeight(fits width: CGFloat, viewModel: DialogViewModelType) -> CGFloat {
    return DialogView.measureHeight(fits: width - 20, viewModel: viewModel) + 20 //top bot margin
  }
}
