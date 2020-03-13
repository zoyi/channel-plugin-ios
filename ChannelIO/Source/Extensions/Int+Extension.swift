//
//  Int+Extension.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/16.
//

extension Int {
  var toBytes: String {
    let bytes = Double(self)
    let KBytes = Double(bytes / 1000)
    let MBytes = Double(bytes / 1000 / 1000)
    if bytes < 1024 {
      return String(format: "%.1fB", bytes)
    } else if KBytes < 1024 {
      return String(format: "%.1fKB", KBytes)
    }
    return String(format: "%.1fMB", MBytes)
  }
}
