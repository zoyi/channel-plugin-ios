//
//  UITableView+Extensions.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 3. 3..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

enum IndicatorPosition {
  case header, footer, content
}

let INDICATOR_SIZE: CGFloat = 20
let INDICATOR_WRAPPER_HEIGHT: CGFloat = 50

extension UITableView {
  func scrollToBottom(_ animated: Bool) {
    guard self.numberOfSections > 0 else { return }
    let indexPath = IndexPath(row: self.numberOfRows(inSection: 0) - 1, section: 0)
    if indexPath.row > 0 {
      self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }
  }
  
  // MARK: indicator related methods
  
  func showIndicatorTo(_ position: IndicatorPosition) {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: INDICATOR_WRAPPER_HEIGHT))
    
    let indicator = NVActivityIndicatorView(frame: CGRect(
      x: 0, y: 0,
      width: INDICATOR_SIZE,
      height: INDICATOR_SIZE))
    indicator.type = .ballRotateChase
    indicator.color = .grey500
    indicator.startAnimating()
    
    view.addSubview(indicator)
    indicator.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
    }
    
    switch position {
    case .header: self.tableHeaderView = view
    case .footer: self.tableFooterView = view
    case .content: self.backgroundView = view
    }
  }
  
  func hideIndicatorTo(_ position: IndicatorPosition) {
    switch position {
    case .header: self.tableHeaderView = nil
    case .footer: self.tableFooterView = nil
    case .content: self.backgroundView = nil
    }
  }
  
  func isLastVisibleCell(at indexPath: IndexPath) -> Bool {
    guard let lastIndexPath = indexPathsForVisibleRows?.last else {
      return false
    }
    
    return lastIndexPath == indexPath
  }
}
