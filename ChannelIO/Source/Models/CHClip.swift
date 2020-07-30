//
//  CHClip.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/09.
//

import Foundation

protocol ThumbDisplayable {
  var width: Int { get set }
  var height: Int { get set }
  var thumbUrl: URL? { get }
  var orientation: Int { get }
}

extension ThumbDisplayable {
  var thumbSize: CGSize {
    let width, height: CGFloat
    switch self.orientation {
    case 5, 6, 7, 8:
      width = CGFloat(self.height)
      height = CGFloat(self.width)
    default:
      width = CGFloat(self.width)
      height = CGFloat(self.height)
    }
    
    let ratio = max(width / CHFile.imageMaxSize.width,
                   height / CHFile.imageMaxSize.height)
    if ratio >= 1.0 {
      return CGSize(width: width / ratio, height: height / ratio)
    } else {
      return CGSize(width: width, height: height)
    }
  }
}

protocol VideoPlayable {
  var duration: Double { get }
  var url: URL? { get }
  var currSeconds: Double? { get }
  var isPlayable: Bool { get }
  var youtubeId: String? { get }
}
