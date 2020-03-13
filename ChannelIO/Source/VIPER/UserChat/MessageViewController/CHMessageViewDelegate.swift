//
//  MessageViewDelegate.swift
//  MessageView
//
//  Created by Ryan Nystrom on 12/22/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit

internal protocol CHMessageViewDelegate: class {
  func sizeDidChange(messageView: CHMessageView)
  func wantsLayout(messageView: CHMessageView)
  func selectionDidChange(messageView: CHMessageView)
  func textViewDidStartEditing(messageView: CHMessageView)
  func textDidChange(text: String)
  func modeDidChange(mode: MessageViewState)
}
