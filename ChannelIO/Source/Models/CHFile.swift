//
//  File.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 6..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Alamofire
import Foundation
import MobileCoreServices
import ObjectMapper
import Photos
import RxSwift

enum FileType: String {
  case video
  case image
  case audio
  case file
  
  init(assetType: PHAssetMediaType) {
    switch assetType {
    case .audio: self = .audio
    case .image: self = .image
    case .video: self = .video
    default: self = .file
    }
  }
}

struct CHFile: ThumbDisplayable {
  var type: FileType = .file
  var id: String = ""
  var name: String = ""
  var size: Int = 0
  var contentType: String?
  var duration: Double = 0.0
  var width: Int = 0
  var height: Int = 0
  var bucket: String = ""
  var key: String = ""
  var previewKey: String = ""
  var thumb: Bool = false

  //local
  var rawData: Data?
  var imageData: UIImage?
  var asset: PHAsset?
  var filePath: URL?

  init(data: Data?, name: String = "") {
    self.id = "\(Date().timeIntervalSince1970 * 1000)" + String.randomString(length: 4)
    self.rawData = data
    self.name = name
  }

  init(asset: PHAsset, name: String = "") {
    self.id = "\(Date().timeIntervalSince1970 * 1000)" + String.randomString(length: 4)
    self.asset = asset
    self.name = name
    self.type = FileType(assetType: asset.mediaType)
  }

  init(image: UIImage?, name: String = "") {
    self.id = "\(Date().timeIntervalSince1970 * 1000)" + String.randomString(length: 4)
    self.imageData = image
    self.name = name
  }

  init(path: URL?, name: String = "") {
    self.id = "\(Date().timeIntervalSince1970 * 1000)" + String.randomString(length: 4)
    self.filePath = url
    self.name = name
  }

  func getData() -> Observable<(Data?, String?)> {
    return Observable.create { subscriber in
      if let rawData = self.rawData {
        subscriber.onNext((rawData, self.name))
        subscriber.onCompleted()
      } else if let imageData = self.imageData,
        let data = imageData.jpegData(compressionQuality: 1.0) {
        subscriber.onNext((data, self.name))
        subscriber.onCompleted()
      } else if let asset = self.asset {
        if self.type == .image {
          let filename = PHAssetResource.assetResources(for: asset).first?.originalFilename
          asset.fetchOriginalImage { image, _ in
            if let data = image?.jpegData(compressionQuality: 1.0) {
              subscriber.onNext((data, filename))
              subscriber.onCompleted()
            }
          }
        } else if self.type == .video {
          let filename = PHAssetResource.assetResources(for: asset).first?.originalFilename
          asset.fetchAVAsset(options: nil, completeBlock: { asset, _ in
            if let asset = asset as? AVURLAsset {
              if let data = try? Data(contentsOf: asset.url) {
                subscriber.onNext((data, filename))
                subscriber.onCompleted()
              }
            }
          })
        } else {
          subscriber.onNext((nil, nil))
          subscriber.onCompleted()
        }
      } else if let url = self.filePath {
        let data = try? Data(contentsOf: url)
        subscriber.onNext((data, self.name))
        subscriber.onCompleted()
      } else {
        subscriber.onNext((nil, nil))
        subscriber.onCompleted()
      }
      
      return Disposables.create()
    }
  }

  var url: URL? {
    guard !self.bucket.isEmpty && !self.key.isEmpty else { return nil }
    let bucket = self.bucket.replace("bin", withString: "cf")
    let urlString = "https://"
      + bucket + "/"
      + (self.key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")
    return URL(string: urlString)
  }
  
  var thumbUrl: URL? {
    guard !self.bucket.isEmpty else { return nil }
    guard self.type == .video || self.type == .image else { return nil }

    let key = !self.previewKey.isEmpty ? self.previewKey : self.key
    let width = Int(self.thumbSize.width)
    let height = Int(self.thumbSize.height)
    let bucket = self.bucket.replace("bin", withString: "cf")
    let thumbable = self.thumb ? "/thumb/" + "\(width)x\(height)/" : "/"
    let urlString = "https://"
      + bucket
      + thumbable
      + (key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")
    return URL(string: urlString)
  }
  
  var isPlayable: Bool {
    guard self.type == .video else { return false }
    return self.duration != 0
  }

  var youtubeId: String? {
    return nil
  }

  var ext: String {
    if type == .video, let contentType = self.contentType {
      return String(contentType.dropFirst("video/".count))
    } else if type == .image, let contentType = self.contentType {
      return String(contentType.dropFirst("image/".count))
    } else {
      guard let key = self.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
        return ""
      }
      return URL(string: key)?.pathExtension ?? ""
    }
  }

  var urlInDocumentsDirectory: URL? {
    let directoryUrl = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let pathUrl = URL(fileURLWithPath: directoryUrl, isDirectory: true)
    let fileUrl = pathUrl.appendingPathComponent(self.id)
    return FileManager.default.fileExists(atPath: fileUrl.path) ? fileUrl : nil
  }

  var isDownloaded: Bool {
    return self.urlInDocumentsDirectory != nil
  }

  var hasData: Bool {
    return self.rawData != nil || self.asset != nil || self.imageData != nil
  }
  
  var image: Observable<UIImage?> {
    guard self.type == .video || self.type == .image else { return .just(nil) }
    guard let asset = self.asset else { return .just(nil) }

    return Observable.create { subscriber in
      if self.type == .video {
        asset.fetchAVAsset { asset, _ in
          let image = CHUtils.getThumbnail(of: asset)
          subscriber.onNext(image)
          subscriber.onCompleted()
        }
      } else {
        asset.fetchOriginalImage { image, _ in
          subscriber.onNext(image)
          subscriber.onCompleted()
        }
      }
      return Disposables.create()
    }
  }
}

extension CHFile: Mappable, Hashable {
  init?(map: Map) {}

  mutating func mapping(map: Map) {
    type <- map["type"]
    id <- map["id"]
    name <- map["name"]
    size <- map["size"]
    contentType <- map["contentType"]
    duration <- map["duration"]
    width <- map["width"]
    height <- map["height"]
    bucket <- map["bucket"]
    key <- map["key"]
    previewKey <- map["previewKey"]
    thumb <- map["thumb"]
  }

  static func == (lhs: CHFile, rhs: CHFile) -> Bool {
    return lhs.id == rhs.id &&
      lhs.name == rhs.name &&
      lhs.size == rhs.size &&
      lhs.type == rhs.type &&
      lhs.contentType == rhs.contentType &&
      lhs.duration == rhs.duration &&
      lhs.bucket == rhs.bucket &&
      lhs.url == rhs.url &&
      lhs.thumb == rhs.thumb
  }
}

extension CHFile {
  static var imageSize = imageDefaultSize
  static var thumbnailImageSize: CGSize {
    let ratio = max(self.imageSize.width / CHFile.imageMaxSize.width,
                   self.imageSize.height / CHFile.imageMaxSize.height)
    if ratio >= 1.0 {
      return CGSize(width: self.imageSize.width / ratio, height: self.imageSize.height / ratio)
    } else {
      return self.imageSize
    }
  }

  static var imageMaxSize: CGSize = {
    let screenSize = UIScreen.main.bounds.size
    return CGSize(width: screenSize.width * 2 / 3, height: screenSize.height / 2)
  }()

  static var imageDefaultSize: CGSize = {
    let screenSize = UIScreen.main.bounds.size
    return CGSize(width: screenSize.width / 2, height: screenSize.height / 4)
  }()
}

extension CHFile {
  static func upload(
    channelId: String,
    filename: String,
    data: Data) -> Observable<([String:Any]?, Double)> {
    return FilePromise.uploadFile(
      channelId: channelId,
      filename: filename,
      data: data
    )
  }
  
  func download() -> Observable<(URL?, Float)> {
    return Observable.create { (subscriber) in
      guard let url = self.url else {
        subscriber.onError(ChannelError.notFoundError)
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
          guard response.response?.statusCode == 200 else {
            subscriber.onError(ChannelError.notFoundError)
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
    }
  }
}
