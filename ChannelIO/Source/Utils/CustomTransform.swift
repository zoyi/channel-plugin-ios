//
//  CustomDateTransform.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 9..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation

class CustomDateTransform: ObjectMapper_TransformType {
  typealias Object = Date
  typealias JSON = Double

  init() {}
  
  func transformFromJSON(_ value: Any?) -> Date? {
    if let timeInt = value as? Double {
      return Date(timeIntervalSince1970: TimeInterval(timeInt / 1000))
    }

    return nil
  }

  func transformToJSON(_ value: Date?) -> Double? {
    if let date = value {
      return Double(date.timeIntervalSince1970 * 1000)
    }
    return nil
  }
}

struct StringTransform: ObjectMapper_TransformType {
  func transformFromJSON(_ value: Any?) -> String? {
    return value.flatMap(String.init(describing:))
  }
  
  func transformToJSON(_ value: String?) -> Any? {
    return value
  }
}

class CustomURLTransform: ObjectMapper_TransformType {
  typealias Object = URL
  typealias JSON = String

  init() {}
  
  func transformFromJSON(_ value: Any?) -> URL? {
    guard let url = value as? String else {
      return nil
    }

    return URL(string: url)
  }

  func transformToJSON(_ value: URL?) -> String? {
    return nil
  }
}

class CustomBlockTransform: ObjectMapper_TransformType {
  static var emojiMap = CHUtils.emojiMap()
  var parser: CHMessageParser

  init(config: CHMessageParserConfig, isInappPush: Bool = false) {
    self.parser = CHMessageParser(
      config: config,
      emojiMap: CustomBlockTransform.emojiMap,
      profiles: userSelector(state: mainStore.state).profile ?? [:],
      isInappPush: isInappPush
    )
  }

  func transformFromJSON(_ value: Any?) -> CHMessageBlock? {
    if var block = ObjectMapper_Mapper<CHMessageBlock>().map(JSONObject: value) {
      let text = self.parser.parse(block: block)
      block.displayText = text
      block.isOnlyEmoji = self.parser.listener?.isOnlyEmoji ?? false
      return block
    }

    return nil
  }

  //not support. cannot parse back to original form
  func transformToJSON(_ value: CHMessageBlock?) -> Any? {
    return nil
  }
}
