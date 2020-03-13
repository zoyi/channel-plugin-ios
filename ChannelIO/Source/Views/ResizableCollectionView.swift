//
//  ResizableCollectionView.swift
//  ChannelIO
//
//  Created by intoxicated on 20/01/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import UIKit

class ResizableTableView: UITableView {
  override func reloadData() {
    super.reloadData()
    self.layoutIfNeeded()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
      self.invalidateIntrinsicContentSize()
    }
  }

  override var intrinsicContentSize: CGSize {
    return contentSize
  }
}

class ResizableCollectionView: UICollectionView {
  override func reloadData() {
    super.reloadData()
    self.layoutIfNeeded()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
      self.invalidateIntrinsicContentSize()
    }
  }

  override var intrinsicContentSize: CGSize {
    return contentSize
  }
}
