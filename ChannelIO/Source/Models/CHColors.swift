//
//  Colors.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 6..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import UIKit

struct CHColors {
  static let dark = UIColor("#516378")!
  static let deepDark = UIColor("#3F4F5F")!
  static let stale10 = UIColor(red: 81/255,
                               green: 99/255, blue: 120/255, alpha: 0.1)
  static let warmPink = UIColor("#ff3d69")!
  static let gray = UIColor("#7C858C")!
  static let white = UIColor.white
  static let black = UIColor.black
  static let yellowishOrange = UIColor("#ffa908")!
  static let lightGray = UIColor("#eef1f4")!
  static let darkTwo = UIColor(red: 81/255,
                               green: 99/255, blue: 120/255, alpha: 0.2)
  static let shamrockGreen = UIColor("#00d63d")!
  static let blueyGrey = UIColor("#98a7b3")!
  static let blueyGrey60 = UIColor(red: 152/255,
                                   green: 167/255, blue: 179/255, alpha: 0.6)
  static let charcoalGrey = UIColor("#2b2f35")!
  static let minicGray = UIColor("#1a516377")!
  static let cobalt = UIColor("#00A6FF")!
  static let light = UIColor("#8696A4")!
  static let azure = UIColor("#00a6ff")!
  static let lightAzure = UIColor("#e6f9ff")!
  static let snow = UIColor("#F3F4F5")!
  static let lightSnow = UIColor("#fbfbfc")!
  static let yellow = UIColor("#ffa908")!
  static let defaultTint = UIColor("#007aff")!
  static let dark10 = UIColor("#3f152128")!
  static let paleGrey = UIColor("#eaeff4")!
  static let iceBlue = UIColor("#ecf9ff")!
  static let paleSkyBlue = UIColor("#b7e7ff")!
  static let white15 = UIColor("#ffffff26")!
  static let white40 = UIColor("#ffffff66")!
  static let dark5 = UIColor("#1521280c")!
  static let dark20 = UIColor("#15212833")!
  static let dark50 = UIColor("#51637888")!
  static let dark80 = UIColor("#516378cc")!
  static let silver = UIColor("#c0c9d0")!
  static let paleGrey20 = UIColor("#eaeff4")!
  static let brightSkyBlue = UIColor("#00c3ff")!
  static let warmGrey = UIColor("#9b9b9b")!
  static let pumpkinOrange = UIColor("#fb8200")!
  
  static func shiftHue(with color: UIColor, shiftValue: CGFloat) -> UIColor {
    let rgba = color.rgba
    let r = rgba.red, g = rgba.green, b = rgba.blue
    let minV:CGFloat = CGFloat(min(r, g, b))
    let maxV:CGFloat = CGFloat(max(r, g, b))
    let delta:CGFloat = maxV - minV
    var hue:CGFloat = 0
    if delta != 0 {
      if r == maxV {
        hue = (g - b) / delta
      }
      else if g == maxV {
        hue = 2 + (b - r) / delta
      }
      else {
        hue = 4 + (r - g) / delta
      }
      hue *= 60
      if hue < 0 {
        hue += 360
      }
    }
    let saturation = maxV == 0 ? 0 : (delta / maxV)
    let brightness = maxV
    
    var finalHue = hue + shiftValue
    if finalHue > 360 {
      finalHue -= 360
    }
    return UIColor(hue: finalHue/360, saturation: saturation, brightness: brightness, alpha: rgba.alpha)
  }
}

extension UIColor {
  var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    return (red, green, blue, alpha)
  }
  
  var hsv: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var brightness: CGFloat = 0
    var alpha: CGFloat = 0
    
    getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    return (hue, saturation, brightness, alpha)
  }
}
