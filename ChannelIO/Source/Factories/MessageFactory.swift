//
//  MessageFactory.swift
//  ChannelIO
//
//  Created by R3alFr3e on 9/26/19.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

struct MessageFactory {
  static func deleted() -> NSAttributedString {
    let font = UIFont.systemFont(ofSize: 15)

    let text = CHAssets.localized("ch.message_stream.message.deleted_message")
    let attrString = NSMutableAttributedString(string: text)
    attrString.addAttribute(.font, value: font, range: NSRange(location: 0, length: attrString.string.count))
    return attrString
  }
}
