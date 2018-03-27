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
  
  init(data: Data, category: String? = nil) {
    self.rawData = data
    self.image = false
    self.category = category ?? ""
  }
  
  init(imageAsset: DKAsset) {
    self.asset = imageAsset
    self.image = true
    let identifier = imageAsset.originalAsset?.value(forKey: "uniformTypeIdentifier") as? String
    if identifier == kUTTypeGIF as String {
      self.category = "gif"
    } else if identifier != kUTTypeQuickTimeImage as String {
      self.category = "image"
    } else { //not handle video or live photo for now
      self.category = "unknown"
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
