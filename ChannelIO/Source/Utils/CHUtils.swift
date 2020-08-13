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
import AVKit

class CHUtils {
  class func getKeyWindow() -> UIWindow? {
    let window: UIWindow?
    if #available(iOS 13.0, *) {
      window = CHUtils
        .getWindowsOnScenes()?
        .filter { $0.isKeyWindow }
        .first
    } else {
      window = UIApplication.shared.keyWindow
    }
    return window
  }
  
  @available(iOS 13.0, *)
  class func getWindowsOnScenes() -> [UIWindow]? {
    return UIApplication.shared
      .connectedScenes
      .map { $0 as? UIWindowScene }
      .compactMap { $0 }
      .first?
      .windows
  }
  
  class func getTopController(
    base: UIViewController? = CHUtils.getKeyWindow()?.rootViewController) -> UIViewController? {
    var currentVc = base
    var previousVc = currentVc
    
    while !(currentVc is UIAlertController) {
      previousVc = currentVc
      if let navigation = (currentVc as? UINavigationController)?.visibleViewController {
        currentVc = navigation
      } else if let tab = (currentVc as? UITabBarController)?.selectedViewController {
        currentVc = tab
      } else if let presented = currentVc?.presentedViewController {
        currentVc = presented
      } else {
        break
      }
    }
    
    if currentVc is UIAlertController {
      if let navigation = (previousVc as? UINavigationController)?.viewControllers.last {
        currentVc = navigation
      }
    }
    
    return currentVc
  }
  
  class func getTopNavigation(
    base: UIViewController? = CHUtils.getKeyWindow()?.rootViewController) -> UINavigationController? {
    if let presented = base?.presentedViewController {
      return getTopNavigation(base: presented)
    }
    if let tab = base as? UITabBarController {
      if let selected = tab.selectedViewController {
        return getTopNavigation(base: selected)
      }
    }
    if let alert = base as? UIAlertController {
      if let presenting = alert.presentingViewController {
        return getTopNavigation(base: presenting)
      }
    }
    if let navigation = base as? UINavigationController {
      return navigation
    }
    
    return base?.navigationController
  }
  
  class func getCurrentSize() -> CGSize {
    let controller = CHUtils.getTopController()
    return controller?.view.bounds.size ?? UIScreen.main.bounds.size
  }
  
  class func nameToExt(name: String) -> String {
    switch name {
      case "png", "image":
        return "image/png"
      case "gif":
        return "image/gif"
      case "json":
        return "application/json"
      default:
        return "text/plain"
    }
  }
  
  class func fileTypesMap() -> [String: String] {
    if let path = CHAssets.getPath(name: "extensions", type: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let jsonArray = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        if let jsonArray = jsonArray as? [Dictionary<String, Any>] {
          return CHUtils.parsefileTypesIntoMap(array: jsonArray)
        }
      } catch {
        return [:]
      }
    }
    
    return [:]
  }
  
  class func parsefileTypesIntoMap(array: [Dictionary<String, Any>]) -> [String: String] {
    var maps: [String: String] = [:]
    for dict in array {
      if let key = dict["key"] as? String, let values = dict["extensions"] as? [String] {
        for value in values {
          maps[value] = key
        }
      }
    }
    
    return maps
  }
  
  class func emojiMap() -> [String: String] {
    if let path = CHAssets.getPath(name: "emojis", type: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        if let jsonResult = jsonResult as? Dictionary<String, Array<Any?>> {
          return CHUtils.parseEmojiIntoMap(dict: jsonResult)
        }
      } catch {
        return [:]
      }
    }
    
    return [:]
  }
  
  class func parseEmojiIntoMap(dict: Dictionary<String, Array<Any?>>) -> [String: String] {
    var maps: [String: String] = [:]
    for emojis in dict.values {
      for each in emojis {
        if let each = each as? Dictionary<String, Any> {
          let key = each["n"] as? String ?? ""
          let value = each["c"] as? String ?? ""
          maps[key] = value
        }
      }
    }
    
    return maps
  }
  
  class func getUrlForUTM(source: String, content: String) -> String {
    return "https://channel.io/ko/?utm_campaign=iOS&utm_source=\(source)&utm_medium=plugin&utm_content=\(content)"
  }
  
  class func getCountryDialCode(countryCode: String) -> String? {
    for each in mainStore.state.countryCodeState.codes {
      if each.code == countryCode {
        return each.dial
      }
    }
    return nil
  }
  
  class func deviceLanguage() -> String? {
    guard let str = NSLocale.preferredLanguages.get(index: 0) else { return nil }
    let start = str.startIndex
    let end = str.index(str.startIndex, offsetBy: 2)
    return String(str[start..<end])
  }
  
  class func stringToLocale(_ localeString: String) -> CHLocale {
    if localeString == "en" {
      return .english
    } else if localeString == "ko" {
      return .korean
    } else if localeString == "ja" {
      return .japanese
    }
    return .english
  }
  
  class func getLocale() -> CHLocaleString? {
    if let settings = ChannelIO.settings, let locale = settings.appLocale {
      return locale
    } else if let config = ChannelIO.bootConfig, let locale = config.appLocale {
      return locale
    } else {
      guard let str = NSLocale.preferredLanguages.get(index: 0) else { return nil }
      let start = str.startIndex
      let end = str.index(str.startIndex, offsetBy: 2)
      let locale = String(str[start..<end])
      
      if locale == "en" {
        return .english
      } else if locale == "ko" {
        return .korean
      } else if locale == "ja" {
        return .japanese
      }
      return .english
    }
  }
  
  class func getCurrentStage() -> ChannelStage {
    return ChannelIO.isNewVersion ? ChannelIO.bootConfig?.stage ?? .production : ChannelIO.settings?.stage ?? .production
  }
  
  class func secondsToComponents(seconds: Int) -> (Int, Int, Int, Int) {
    return (seconds/86400,
            (seconds%86400)/3600,
            ((seconds%86400)%3600)/60,
            (((seconds%86400)%3600)%60))
  }
  
  class func secondsToRedableString(seconds: Int) -> String {
    let components = CHUtils.secondsToComponents(seconds: seconds)
    if components.0 > 0 {
      return String(format: CHAssets.localized("%d day"), components.0)
    }
    else if components.1 > 0 {
      return "\(components.1)" + CHAssets.localized("ch.review.complete.time.hour")
    }
    else if components.2 > 0 {
      return "\(components.2)" + CHAssets.localized("ch.review.complete.time.minute")
    }
    else {
      return "1" + CHAssets.localized("ch.review.complete.time.minute")
    }
  }

  @discardableResult
  class func saveToDisk<T: Encodable>(with name: String, object: T) -> Bool {
    var data:Data?
    do {
      data = try JSONEncoder().encode(object)
      guard let data = data else { return false }
      let fm = FileManager.default
      let url1 = try fm.url(
        for:.applicationSupportDirectory,
        in:[.userDomainMask],
        appropriateFor:nil, create:true)
      let url2 = url1.appendingPathComponent(name)
      try data.write(to:url2)
      return true
    } catch {
      return false
    }
  }
  
  class func readFromDisk<T: Decodable>(with name: String, type: T.Type) -> Any? {
    do {
      let fm = FileManager.default
      let decoder = JSONDecoder()
      let url1 = try fm.url(
        for:.applicationSupportDirectory,
        in:[.userDomainMask],
        appropriateFor:nil, create:true)
      let url2 = url1.appendingPathComponent(name)

      if let data = try? Data(contentsOf: url2),
        let object = try? decoder.decode(type, from: data) {
        return object
      }
      return nil
    } catch {
      return nil
    }
  }
  
  class func generateUserAgent() -> String {
    let deviceType = UIDevice.current.model.hasPrefix("iPad") ? "iPad" : "iPhone"
    var ua = "Mozilla/5.0"
    ua += " (\(deviceType);"
    ua += " CPU"
    ua += deviceType == "iPhone" ? " iPhone" : ""
    ua += " OS \(UIDevice.current.systemVersion.replace(".", withString: "_"))"
    ua += " like Mac OS X)"
    ua += " AppleWebKit/600.1.4 (KHTML, like Gecko)"
    ua += " Mobile"
    //Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_2 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile
    return ua
  }
  
  class func getHostAppInfo() -> String? {
    guard
      let appBundleId = Bundle.main.bundleIdentifier,
      let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
      return nil
    }
    
    return "\(appBundleId)/\(appVersion)"
  }
  
  static func getSdkVersion() -> String? {
    let version = Bundle(for: ChannelIO.self)
      .infoDictionary?["CFBundleShortVersionString"] as? String
    return version
  }
  
  class func jsonStringify(data: Any?) -> String? {
    guard let data = data else { return nil }
    
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed)
      let jsonString = String(data: jsonData, encoding: .utf8)
      return jsonString
    } catch {
      return nil
    }
  }
  
  class func getServerErrorMessage(data: Data?) -> [String]? {
    guard let data = data else { return nil }
    
    let json = SwiftyJSON.JSON(data)
    
    guard
      let errors: [CHError] = Mapper<CHError>().mapArray(JSONObject: json["errors"].object) else {
      return nil
    }
    
    return errors.map { $0.message }
  }
  
  class func getThumbnail(of asset: AVAsset?) -> UIImage? {
    guard let asset = asset else { return nil }
    let assetImgGenerate = AVAssetImageGenerator(asset: asset)
    assetImgGenerate.appliesPreferredTrackTransform = true
    let time = CMTimeMake(value: Int64(1), timescale: 100)
    do {
      let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
      let thumbnail = UIImage(cgImage: img)
      return thumbnail
    } catch {
      return nil
    }
  }
}

typealias dispatchClosure = () -> Void

func dispatch(delay: Double = 0.0, execute: @escaping dispatchClosure) {
  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: {
    execute()
  })
}

func dispatchSyncOnBack (execute: @escaping dispatchClosure) {
  DispatchQueue.global(qos: .background).sync {
    execute()
  }
}

func dispatchAsyncOnBack (delay: Double = 0.0, execute: @escaping dispatchClosure) {
  DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + delay, execute: {
    execute()
  })
}

extension TimeInterval {
  
  /**
   Checks if `since` has passed since `self`.
   
   - Parameter since: The duration of time that needs to have passed for this function to return `true`.
   - Returns: `true` if `since` has passed since now.
   */
  func hasPassed(since: TimeInterval) -> Bool {
    return Date().timeIntervalSinceReferenceDate - self > since
  }
  
}
/**
 Wraps a function in a new function that will throttle the execution to once in every `delay` seconds.
 
 - Parameter delay: A `TimeInterval` specifying the number of seconds that needst to pass between each execution of `action`.
 - Parameter queue: The queue to perform the action on. Defaults to the main queue.
 - Parameter action: A function to throttle.
 
 - Returns: A new function that will only call `action` once every `delay` seconds, regardless of how often it is called.
 */
func throttle(delay: TimeInterval, queue: DispatchQueue = .main, action: @escaping (() -> Void)) -> () -> Void {
  var currentWorkItem: DispatchWorkItem?
  var lastFire: TimeInterval = 0
  return {
    guard currentWorkItem == nil else { return }
    currentWorkItem = DispatchWorkItem {
      action()
      lastFire = Date().timeIntervalSinceReferenceDate
      currentWorkItem = nil
    }
    if delay.hasPassed(since: lastFire) {
      queue.async(execute: currentWorkItem!)
    } else {
      currentWorkItem = nil
    }
  }
}

func throttle<T>(delay: TimeInterval, queue: DispatchQueue = .main, action: @escaping ((T) -> Void)) -> (T) -> Void {
  var currentWorkItem: DispatchWorkItem?
  var lastFire: TimeInterval = 0
  return { (p1: T) in
    guard currentWorkItem == nil else { return }
    currentWorkItem = DispatchWorkItem {
      action(p1)
      lastFire = Date().timeIntervalSinceReferenceDate
      currentWorkItem = nil
    }
    //if time has passed, execute workitem. Otherwise, abandon work
    if delay.hasPassed(since: lastFire) {
      queue.async(execute: currentWorkItem!)
    } else {
      currentWorkItem = nil
    }
  }
}

