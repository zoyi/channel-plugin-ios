//
//  Animator.swift
//  ChannelIO
//
//  Created by Haeun Chung on 24/01/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

typealias TableViewAnimation = (UITableViewCell, IndexPath, UITableView) -> Void

final class TableViewAnimator {
  private var hasAnimatedAllCells = false
  private let animation: TableViewAnimation
  
  init(animation: @escaping TableViewAnimation) {
    self.animation = animation
  }
  
  func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
    guard !hasAnimatedAllCells else {
      return
    }
    
    animation(cell, indexPath, tableView)
    hasAnimatedAllCells = tableView.isLastVisibleCell(at: indexPath)
  }
}


enum AnimationFactory {
  static func makeFadeAnimation(duration: TimeInterval, delayFactor: Double) -> TableViewAnimation {
    return { cell, indexPath, _ in
      cell.alpha = 0
      
      UIView.animate(
        withDuration: duration,
        delay: delayFactor * Double(indexPath.row),
        animations: {
          cell.alpha = 1
      })
    }
  }
  
  static func makeMoveUpWithBounce(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> TableViewAnimation {
    return { cell, indexPath, tableView in
      cell.transform = CGAffineTransform(translationX: 0, y: rowHeight)
      
      UIView.animate(
        withDuration: duration,
        delay: delayFactor * Double(indexPath.row),
        usingSpringWithDamping: 0.4,
        initialSpringVelocity: 0.1,
        options: [.curveEaseInOut],
        animations: {
          cell.transform = CGAffineTransform(translationX: 0, y: 0)
      })
    }
  }
}
