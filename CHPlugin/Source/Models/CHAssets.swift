//
//  Assets.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import AVFoundation

class CHAssets {
  class func mainBundle() -> Bundle {
    return Bundle(for: self)
  }
  
  class func getImage(named: String) -> UIImage? {
    let bundle = Bundle(for: self)
    return UIImage(named: named, in: bundle, compatibleWith: nil)
  }

  class func localized(_ key: String) -> String {
    let bundle = Bundle(for: self)
    return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
  }
  
  class func attributedLocalized(_ key: String) -> NSMutableAttributedString {
    let bundle = Bundle(for: self)
    let localizedString = NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
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
  
  class func playPushSound() {
    let pushSound = NSURL(fileURLWithPath: Bundle(for:self).path(forResource: "ringtone", ofType: "mp3")!)
    var soundId: SystemSoundID = 0
    AudioServicesCreateSystemSoundID(pushSound, &soundId)
    AudioServicesPlaySystemSound(soundId)
  }
}
