//
//  File.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 6..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import RxSwift
import Alamofire
import Photos

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
  var previewThumb: CHImageMeta?
  var imageRedirectUrl: String?
  
  var isPreviewable: Bool! {
    return self.image == true && self.previewThumb != nil
  }
  
  //local
  var rawData: Data?
  var asset: PHAsset?
  var imageData: UIImage?
  var downloaded: Bool = false
  var localUrl: URL?
  var fileUrl: URL?
  
  var mimeType: Mimetype? {
    if let identifier = self.asset?.value(forKey: "uniformTypeIdentifier") as? String {
      return CHFile.convertToMimetype(from: identifier)
    } else if self.imageData != nil {
      return .image
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
  
  var urlInDocumentsDirectoryString = ""
  var urlInDocumentsDirectory: URL? {
    set {
      if let path = newValue?.path {
        self.urlInDocumentsDirectoryString = path
      }
    }
    get {
      return URL(fileURLWithPath: self.urlInDocumentsDirectoryString)
    }
  }
  
  var isDownloaded: Bool {
    get {
      return FileManager.default.fileExists(atPath: self.urlInDocumentsDirectoryString)
    }
  }
  
  init() {
    
  }
  
  init(data: Data, category: String? = nil) {
    self.rawData = data
    self.image = false
    self.category = category ?? ""
  }
  
  init(asset: PHAsset) {
    self.asset = asset
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
  
  init(imageData: UIImage) {
    self.imageData = imageData
    self.image = true
    self.category = "image"
  }
  
  static func convertToMimetype(from name: String) -> Mimetype {
    switch name {
    case "png", "image", "public.heic", String(kUTTypeImage), String(kUTTypeJPEG), String(kUTTypePNG):
      return .image
    case "gif", String(kUTTypeGIF):
      return .gif
    case "json":
      return .json
    case "mp4", "public.mpeg-4", String(kUTTypeVideo), String(kUTTypeQuickTimeMovie), String(kUTTypeMovie):
      return .video
    case "mp3", "wav", "ogg", String(kUTTypeAudio):
      return .audio
    default:
      return .plain
    }
  }
  
  static func create(imageable: CHImageable) -> CHFile? {
    if let url = imageable.imageUrl {
      var file = CHFile()
      file.url = url
      file.image = true
      file.previewThumb = imageable.imageMeta
      file.imageRedirectUrl = imageable.imageRedirectUrl
      return file
    }

    return nil
  }
}

extension CHFile: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    url                 <- map["url"]
    name                <- map["name"]
    filename            <- map["filename"]
    size                <- map["size"]
    category            <- map["extension"]
    image               <- map["image"]
    previewThumb        <- map["previewThumb"]
    imageRedirectUrl    <- map["imageRedirectUrl"]
    fileUrl = URL(string: url)
  }
}

extension CHFile {
  func download() -> Observable<(URL?, Float)> {
    return Observable.create({ (subscriber) in
      let error: NSError = NSError(domain: "download", code: 404, userInfo: nil)
      guard let url = self.fileUrl else {
        subscriber.onError(error)
        return Disposables.create()
      }
      
      if self.isDownloaded {
        subscriber.onNext((self.urlInDocumentsDirectory, 100))
        subscriber.onCompleted()
        return Disposables.create()
      }
      
      let destination: DownloadRequest.DownloadFileDestination = { _, response in
        let documentsURL:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL:URL = documentsURL.appendingPathComponent(response.suggestedFilename!)
        
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
      }
      
      let req = Alamofire.download(url, to: destination)
        .downloadProgress { (download) in
          DispatchQueue.main.async() {
            subscriber.onNext((nil, Float(download.fractionCompleted)))
          }
        }.validate(statusCode: 200..<300)
        .response { (response) in
          //SVProgressHUD.dismiss()
          guard response.response?.statusCode == 200 else {
            subscriber.onError(error)
            return
          }
          
          let directoryURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
          let pathURL = URL(fileURLWithPath: directoryURL, isDirectory: true)
          guard let fileName = response.response?.suggestedFilename else { return }
          let fileURL = pathURL.appendingPathComponent(fileName)
          
          subscriber.onNext((fileURL, 1))
          subscriber.onCompleted()
      }
      return Disposables.create {
        req.cancel()
      }
    })
  }
}
