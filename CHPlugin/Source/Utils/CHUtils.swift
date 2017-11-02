//
//  Utils.swift
//  CHPlugin
//
//  Created by Haeun Chung on 13/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

class CHUtils {
  class func getTopController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let navigation = base as? UINavigationController {
      return getTopController(base: navigation.visibleViewController)
    }
    if let tab = base as? UITabBarController {
      if let selected = tab.selectedViewController {
        return getTopController(base: selected)
      }
    }
    if let presented = base?.presentedViewController {
      return getTopController(base: presented)
    }
    
    return base
  }
  
  class func getTopNavigation(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UINavigationController? {
    if let navigation = base as? UINavigationController {
      return navigation
    }
    if let tab = base as? UITabBarController {
      if let selected = tab.selectedViewController {
        return getTopNavigation(base: selected)
      }
    }
    if let presented = base?.presentedViewController {
      return getTopNavigation(base: presented)
    }
    
    return base?.navigationController
  }
  
  class func nameToExt(name: String) -> String {
    switch name {
      case "png", "image":
        return "image/png"
      case "json":
        return "application/json"
      default:
        return "text/plain"
    }
  }
  
  class func getCountryDialCode(countryCode: String) -> String? {
    if let countries = CHUtils.getCountryInfo() {
      for each in countries {
        if each.code == countryCode {
          return each.dial
        }
      }
    }
    
    return nil
  }
  
  class func getCountryInfo() -> [CHCountry]? {
    let bundle = Bundle(for: self)
    if let path = bundle.path(forResource: "countryInfo", ofType: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
        let jsonObj = JSON(data: data)
        if jsonObj != JSON.null {
          return Mapper<CHCountry>()
            .mapArray(JSONObject: jsonObj.object)
        } else {
          print("Could not get json from file, make sure that file contains valid json.")
          return nil
        }
      } catch _ {
        return nil
      }
    }
    
    return nil
  }
  
  class func getLocale() -> String? {
    guard let str = NSLocale.preferredLanguages.get(index: 0) else { return nil }
    let start = str.startIndex
    let end = str.index(str.startIndex, offsetBy: 2)
    let range = start..<end
    let locale = str.substring(with: range)
    
    return locale
  }
  
  class func getCurrentStage() -> String? {
    return Bundle(for: self).object(forInfoDictionaryKey: "Stage") as? String
  }
  
  class func secondsToComponents(seconds: Int) -> (Int, Int, Int, Int) {
    return (seconds/86400,
            (seconds%86400)/3600,
            ((seconds%86400)%3600)/60,
            (((seconds%86400)%3600)%60))
  }
  
  class func secondsToRedableString(seconds: Int) -> String {
    let components = CHUtils.secondsToComponents(seconds: seconds)
    var durationText = ""
    if components.0 > 0 {
      durationText += String(format: CHAssets.localized("%d day"), components.0)
    }
    if components.1 > 0 {
      durationText += "\(components.1)" + CHAssets.localized("ch.review.complete.time.hour")
    }
    if components.2 > 0 {
      durationText += "\(components.2)" + CHAssets.localized("ch.review.complete.time.minute")
    }
    if components.2 == 0 && components.3 > 0 {
      durationText += "1" + CHAssets.localized("ch.review.complete.time.minute")
    }
    
    return durationText
  }
}

typealias dispatchClosure = () -> Void

func dispatch (delay: Double = 0.0, execute: @escaping dispatchClosure) {
  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: {
    execute()
  })
}
