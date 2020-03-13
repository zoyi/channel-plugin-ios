//
//  MessageViewController+MessageViewDelegate.swift
//  MessageView
//
//  Created by Ryan Nystrom on 12/22/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit

extension CHMessageViewController: CHMessageViewDelegate {
  @objc func textDidChange(text: String) {
    self.messageView.rightButtonIsEnable = self.messageView.shouldEnabledSend
  }

  internal func sizeDidChange(messageView: CHMessageView) {
    UIView.animate(withDuration: 0.25) {
      self.layout(updateOffset: true)
    }
  }

  internal func wantsLayout(messageView: CHMessageView) {
    view.setNeedsLayout()
  }

  internal func selectionDidChange(messageView: CHMessageView) {}
  internal func textViewDidStartEditing(messageView: CHMessageView) {}
  internal func modeDidChange(mode: MessageViewState) {
    switch mode {
    case .normal:
      self.paintSafeAreaBottomInset(with: nil)
    case .highlight:
      self.paintSafeAreaBottomInset(with: UIColor.orange100)
    case .disabled:
      self.paintSafeAreaBottomInset(with: UIColor.grey200)
    }
  }
}
