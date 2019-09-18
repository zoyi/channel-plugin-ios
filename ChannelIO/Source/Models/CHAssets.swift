 //
//  Assets.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import AVFoundation

class CHAssets {
  class func getBundle() -> Bundle {
    if let bundlePath = Bundle(for: self).path(forResource: "ChannelIO", ofType: "bundle"),
      let bundle = Bundle.init(path: bundlePath) {
     return bundle
    }
    return Bundle(for: self)
  }
  
  class func getImage(named: String) -> UIImage? {
    let bundle = CHAssets.getBundle()
    return UIImage(named: named, in: bundle, compatibleWith: nil)
  }

  class func getPath(name: String, type: String) -> String? {
    let bundle = CHAssets.getBundle()
    return bundle.path(forResource: name, ofType: type)
  }
  
  class func getData(named: String, type: String) -> Data? {
    let bundle = CHAssets.getBundle()

    if #available(iOS 9.0, *) {
      return NSDataAsset(name: named, bundle: bundle)?.data
    } else {
      do {
        guard let url = try bundle.path(forResource: named, ofType: type)?.asURL() else {
          return nil
        }
        return try Data(contentsOf: url)
      } catch {
        return nil
      }
    }
  }
  
  class func localized(_ key: String) -> String {
    let rootBundle = CHAssets.getBundle()
    if let settings = ChannelIO.settings, let locale = settings.appLocale?.rawValue {
      guard let path = rootBundle.path(forResource: locale, ofType: "lproj") else { return "" }
      guard let bundle = Bundle.init(path: path) else { return "" }
      return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "").replace("%s", withString: "%@")
    } else {
      return NSLocalizedString(key, tableName: nil, bundle: rootBundle, value: "", comment: "").replace("%s", withString: "%@")
    }
  }
  
  class func attributedLocalized(_ key: String) -> NSMutableAttributedString {
    let bundle = CHAssets.getBundle()
    let localizedString = NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "").replace("%s", withString: "%@")
    let data = localizedString.data(using: .utf16)
    do {
      let result = try NSMutableAttributedString(
        data: data!,
        options: [.documentType: NSAttributedString.DocumentType.html],
        documentAttributes: nil)
      return result
    } catch _ {
      return NSMutableAttributedString(string: localizedString)
    }
  }
  
  class func localized(
    _ key: String,
    attributes: [NSAttributedString.Key: Any],
    tagAttributes: [StringTagType: [NSAttributedString.Key: Any]]? = nil) -> NSAttributedString {
    
    var locale = "en"
    if let settings = ChannelIO.settings, let settingLocale = settings.appLocale?.rawValue {
      locale = settingLocale
    }
    
    let rootBundle = CHAssets.getBundle()
    guard let path = rootBundle.path(forResource: locale, ofType: "lproj") else {
      return NSAttributedString(string: key)
    }
    guard let bundle = Bundle.init(path: path) else {
      return NSAttributedString(string: key)
    }
    
    var keyString = NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "").replace("%s", withString: "%@")
    //replace <br /> tag with newline
    keyString = keyString.replace("<br />", withString: "\n")
    
    let attributedString = NSMutableAttributedString(string: keyString)
    
    attributedString.addAttributes(attributes, range: NSRange(location: 0, length: keyString.utf16.count))
    
    if tagAttributes == nil {
      return attributedString
    }
    
    if let tagAttributes = tagAttributes {
      for (tag, attrs) in tagAttributes {
        do {
          let pattern = "<\(tag.rawValue)>(.*?)</\(tag.rawValue)>"
          let startTag = "<\(tag.rawValue)>"
          let endTag = "</\(tag.rawValue)>"
          
          let regex = try NSRegularExpression(pattern: pattern) //\(startTag)(.*)\(endTag)")
          let results = regex.matches(in: keyString, range: NSRange(keyString.startIndex..., in: keyString))
          
          var adjustLocation = 0
          results.forEach { (result) in
            let regexResultRange = NSRange(location: result.range.location - adjustLocation, length: result.range.length)
            attributedString.addAttributes(attrs, range: regexResultRange)
            let startTagRange = NSRange(location: result.range.location - adjustLocation, length: startTag.count)
            let endTagRange = NSRange(location: result.range.location - adjustLocation + result.range.length - endTag.count, length: endTag.count)
            
            attributedString.replaceCharacters(in: endTagRange, with: "")
            attributedString.replaceCharacters(in: startTagRange, with: "")
            
            adjustLocation = startTag.count + endTag.count
          }
        } catch let error {
          print("invalid regex: \(error.localizedDescription)")
          return attributedString
        }
      }
    }
    
    return attributedString
    
  }
  
  class func playPushSound() {
    let bundle = CHAssets.getBundle()
    let pushSound = NSURL(fileURLWithPath: bundle.path(forResource: "ringtone", ofType: "mp3")!)
    var soundId: SystemSoundID = 0
    AudioServicesCreateSystemSoundID(pushSound, &soundId)
    
    Mute.shared.checkInterval = 0.5
    Mute.shared.alwaysNotify = true
    Mute.shared.isPaused = false
    Mute.shared.schedulePlaySound()
    Mute.shared.notify = { m in
      if !m {
        AudioServicesPlaySystemSound(soundId)
      } else {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
      }
      Mute.shared.isPaused = true
      Mute.shared.alwaysNotify = false
    }
  }
}
 
extension CHAssets {
  static func normalIcon() -> UIImage? {
    return CHAssets.getImage(named: "bubbleFilled")
  }
  
  static func normalBlackIcon() -> UIImage? {
    return CHAssets.getImage(named: "bubbleStroke")
  }
  
  static func pushIcon() -> UIImage? {
    return CHAssets.getImage(named: "bubbleFilledPush")
  }
  
  static func pushBlackIcon() -> UIImage? {
    return CHAssets.getImage(named: "bubbleStrokePush")
  }
  
  static func upIcon() -> UIImage? {
    return CHAssets.getImage(named: "bubbleFilledUp")
  }
  
  static func upBlackIcon() -> UIImage? {
    return CHAssets.getImage(named: "bubbleStrokeUp")
  }
  
  static func upRightIcon() -> UIImage? {
    return CHAssets.getImage(named: "bubbleFilledUpRight")
  }
  
  static func upRightBlackIcon() -> UIImage? {
    return CHAssets.getImage(named: "bubbleStrokeUpRight")
  }
}
