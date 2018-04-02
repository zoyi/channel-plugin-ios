//
//  File.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 6..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper
import DKImagePickerController
import MobileCoreServices

enum Mimetype: String {
  case image = "image/png"
  case video = "video/mp4"
  case gif = "image/gif"
  
  //TBD
  case json = "application/json"
  case plain = "text/plain"
  case pdf = "application/pdf"
  case audio = "audio/aac"
  case ppt = "application/vnd.ms-powerpoint"
}

struct CHFile {
  var url = ""
  var name = ""
  var filename = ""
  var size = 0
  var category = ""
  var image = false
  var previewThumb: CHPreviewThumb?

  var isPreviewable: Bool! {
    return self.image == true && self.previewThumb != nil
  }
  
  //local
  var rawData: Data?
  var asset: DKAsset?
  var downloaded: Bool = false
  var localUrl: URL?
  var fileUrl: URL?
  
  var mimeType: Mimetype? {
    if let identifier = self.asset?.originalAsset?.value(forKey: "uniformTypeIdentifier") as? String {
      return CHFile.convertToMimetype(from: identifier)
    }
    return nil
  }
  
  var readableSize: String {
    get {
      let KB = ceil(Double(self.size / 1024))
      let MB = ceil(Double(self.size / 1024 / 1024))
      if KB < 1024 {
        return "\(KB) KB"
      } else {
        return "\(MB) MB"
      }
    }
  }
  
  init(data: Data, category: String? = nil) {
    self.rawData = data
    self.image = false
    self.category = category ?? ""
  }
  
  init(imageAsset: DKAsset) {
    self.asset = imageAsset
    self.image = self.mimeType == .image || self.mimeType == .gif
    
    if let mineType = self.mimeType {
      switch mineType {
      case .image:
        self.category = "image"
      case .video:
        self.category = "video"
      case .gif:
        self.category = "gif"
      default:
        self.category = ""
      }
    }
  }
  
  static func convertToMimetype(from name: String) -> Mimetype {
    switch name {
    case "png", "image", String(kUTTypeImage), String(kUTTypeJPEG), String(kUTTypePNG):
      return .image
    case "gif", String(kUTTypeGIF):
      return .gif
    case "json":
      return .json
    case "mp4", String(kUTTypeVideo), String(kUTTypeQuickTimeMovie), String(kUTTypeMovie):
      return .video
    case "mp3", "wav", "ogg", String(kUTTypeAudio):
      return .audio
    default:
      return .plain
    }
  }
}

extension CHFile: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    url          <- map["url"]
    name         <- map["name"]
    filename     <- map["filename"]
    size         <- map["size"]
    category     <- map["extension"]
    image        <- map["image"]
    previewThumb <- map["previewThumb"]
    
    fileUrl = URL(string: url)
  }
}
