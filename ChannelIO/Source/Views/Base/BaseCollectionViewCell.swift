//
//  MediaCollectionViewCell.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/16.
//

import Reusable
import UIKit

class BaseCollectionViewCell: UICollectionViewCell, Reusable {
  // MARK: Initializing
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.initialize()
    self.setLayouts()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func initialize() {
    // Override point
  }

  func setLayouts() {
  }
}

