//
//  WebPage.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 6..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper

struct CHWebPage: ThumbDisplayable, VideoPlayable {
  var id = ""
  var url: URL?
  var title: String?
  var desc: String?
  var videoUrl: String?
  var publisher: VideoPublisher?
  var author: String?
  var width: Int = 0
  var height: Int = 0
  var orientation: Int = 0
  var bucket: String = ""
  var previewKey: String = ""

  //videoPlayable
  var currSeconds: Double?
  var duration: Double = 0.0

  var isPlayable: Bool {
    return self.publisher != nil && self.url != nil
  }

  var youtubeId: String? {
    if self.publisher != .youtube {
      return nil
    }
    return self.url?.queryItemForKey("v")?.value
  }

  var thumbUrl: URL? {
    guard !self.bucket.isEmpty && !self.previewKey.isEmpty else { return nil }
    let bucket = self.bucket.replace("bin", withString: "cf")
    let urlString = "https://" + bucket + "/thumb/" + "\(self.width)x\(self.height),cover/" + self.previewKey
    return URL(string: urlString)
  }
}

extension CHWebPage: Mappable {
  init?(map: Map) {}

  mutating func mapping(map: Map) {
    id <- map["id"]
    url <- (map["url"], CustomURLTransform())
    title <- map["title"]
    desc <- map["description"]
    videoUrl <- map["videoUrl"]
    publisher <- map["publisher"]
    author <- map["author"]
    width <- map["width"]
    height <- map["height"]
    orientation <- map["orientation"]
    bucket <- map["bucket"]
    previewKey <- map["previewKey"]
  }
}

extension CHWebPage: Equatable {
  static func == (lhs: CHWebPage, rhs: CHWebPage) -> Bool {
    return lhs.id == rhs.id &&
      lhs.url == rhs.url &&
      lhs.title == rhs.title &&
      lhs.desc == rhs.desc &&
      lhs.videoUrl == rhs.videoUrl &&
      lhs.publisher == rhs.publisher &&
      lhs.author == rhs.author &&
      lhs.width == rhs.width &&
      lhs.height == rhs.height &&
      lhs.orientation == rhs.orientation &&
      lhs.bucket == rhs.bucket &&
      lhs.previewKey == rhs.previewKey
  }
}

enum VideoPublisher: String {
  case youtube = "YouTube"
  case vimeo

  var name: String {
    switch self {
    case .youtube: return "YouTube"
    case .vimeo: return "Vimeo"
    }
  }

  var image: UIImage? {
    switch self {
    case .youtube: return CHAssets.getImage(named: "logoYoutube")
    default: return nil
    }
  }
}
