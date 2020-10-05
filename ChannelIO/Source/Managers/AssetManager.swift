//
//  AssetManager.swift
//  ChannelIO
//
//  Created by R3alFr3e on 9/30/19.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import Photos

typealias ImageRequestId = Int32
typealias DataCompletion = (_ data: Data?, _ info: [AnyHashable: Any]?) -> Void
typealias AVAssetCompletion = (_ avAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void

class AssetManager {
  static let shared = AssetManager()

  private let manager = PHCachingImageManager()
  private var requestIDs = [ImageRequestId: PHImageRequestID]()
  private var finishedRequestIDs = Set<ImageRequestId>()
  private var cancelledRequestIDs = Set<ImageRequestId>()

  private lazy var imageRequestOptions: PHImageRequestOptions = {
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    return options
  }()

  private lazy var videoRequestOptions: PHVideoRequestOptions = {
    let options = PHVideoRequestOptions()
    options.deliveryMode = .mediumQualityFormat
    options.isNetworkAccessAllowed = true
    return options
  }()

  private init() { }

  func getSeed() -> ImageRequestId {
    return 0
  }

  private func update(
    requestID: ImageRequestId,
    with imageRequestID: PHImageRequestID?,
    old oldImageRequestID: ImageRequestId?) {
    dispatch {
      if let imageRequestID = imageRequestID {
        if self.cancelledRequestIDs.contains(requestID) {
          self.cancelledRequestIDs.remove(requestID)
          self.manager.cancelImageRequest(imageRequestID)
        } else {
          if self.finishedRequestIDs.contains(requestID) {
            self.finishedRequestIDs.remove(requestID)
          } else {
            self.requestIDs[requestID] = imageRequestID
          }
        }
      } else {
        self.requestIDs[requestID] = nil
      }
    }
  }

  private func update(requestID: ImageRequestId, with info: [AnyHashable: Any]?) {
    guard let info = info else { return }

    if let isCancelled = info[PHImageCancelledKey] as? NSNumber, isCancelled.boolValue {
      dispatch {
        self.requestIDs[requestID] = nil
        self.cancelledRequestIDs.remove(requestID)
      }
    } else if let isDegraded = (info[PHImageResultIsDegradedKey] as? NSNumber)?.boolValue {
      if !isDegraded { // No more callbacks for the requested image.
        dispatch {
          if self.requestIDs[requestID] == nil {
            self.finishedRequestIDs.insert(requestID)
          } else {
            self.requestIDs[requestID] = nil
          }
        }
      }
    }
  }

  func cancelRequest(requestID: ImageRequestId) {
    self.cancelRequests(requestIDs: [requestID])
  }

  func cancelRequests(requestIDs: [ImageRequestId]) {
    dispatch {
      while self.cancelledRequestIDs.count > 100 {
        _ = self.cancelledRequestIDs.popFirst()
      }

      for requestID in requestIDs {
        if let imageRequestID = self.requestIDs[requestID] {
          self.manager.cancelImageRequest(imageRequestID)
          self.cancelledRequestIDs.insert(requestID)
        }

        self.requestIDs[requestID] = nil
      }
    }
  }

  @discardableResult
  func fetchImageData(
    for asset: PHAsset,
    options: PHImageRequestOptions? = nil,
    completeBlock: @escaping DataCompletion) -> ImageRequestId {
    return self.fetchImageData(
      for: asset,
      options: options,
      oldRequestID: nil,
      completeBlock: completeBlock
    )
  }

  @discardableResult
  private func fetchImageData(
    for asset: PHAsset?,
    options: PHImageRequestOptions?,
    oldRequestID: ImageRequestId?,
    completeBlock: @escaping DataCompletion) -> ImageRequestId {
    let requestID = oldRequestID ?? self.getSeed()

    guard let asset = asset else {
      assertionFailure("Expect asset")
      completeBlock(nil, nil)
      return requestID
    }

    let requestOptions = options ?? self.imageRequestOptions
    let imageRequestID = self.manager.requestImageData(
      for: asset,
      options: requestOptions) { data, _, _, info in
      self.update(requestID: requestID, with: info)

      if let info = info,
        let isCancelled = info[PHImageCancelledKey] as? NSNumber,
        isCancelled.boolValue {
        completeBlock(data, info)
        return
      }

      if let isInCloud = info?[PHImageResultIsInCloudKey] as AnyObject?,
        data == nil,
        isInCloud.boolValue,
        !requestOptions.isNetworkAccessAllowed {
        if self.cancelledRequestIDs.contains(requestID) {
          self.cancelledRequestIDs.remove(requestID)
          completeBlock(nil, [PHImageCancelledKey: NSNumber(value: 1)])
          return
        }

        guard let requestCloudOptions = requestOptions.copy() as? PHImageRequestOptions else {
          assertionFailure("Expect PHImageRequestOptions")
          completeBlock(nil, nil)
          return
        }

        requestCloudOptions.isNetworkAccessAllowed = true

        self.fetchImageData(
          for: asset,
          options: requestCloudOptions,
          oldRequestID: requestID,
          completeBlock: completeBlock
        )
      } else {
        completeBlock(data, info)
      }
    }

    self.update(requestID: requestID, with: imageRequestID, old: oldRequestID)
    return requestID
  }

  @discardableResult
  func fetchAVAsset(
    for asset: PHAsset,
    options: PHVideoRequestOptions? = nil,
    completeBlock: @escaping AVAssetCompletion) -> ImageRequestId {
    return self.fetchAVAsset(
      for: asset,
      options: options,
      oldRequestID: nil,
      completeBlock: completeBlock
    )
  }

  @discardableResult
  private func fetchAVAsset(
    for asset: PHAsset?,
    options: PHVideoRequestOptions?,
    oldRequestID: ImageRequestId?,
    completeBlock: @escaping AVAssetCompletion) -> ImageRequestId {
    let requestID = oldRequestID ?? self.getSeed()

    guard let asset = asset else {
      assertionFailure("Expect originalAsset")
      completeBlock(nil, nil)
      return requestID
    }

    let requestOptions = options ?? self.videoRequestOptions
    let imageRequestID = self.manager.requestAVAsset(
      forVideo: asset,
      options: requestOptions) { avAsset, _, info in
      self.update(requestID: requestID, with: info)

      if let info = info,
        let isCancelled = info[PHImageCancelledKey] as? NSNumber,
        isCancelled.boolValue {
          completeBlock(avAsset, info)
          return
      }

      if let isInCloud = info?[PHImageResultIsInCloudKey] as AnyObject?,
        avAsset == nil,
        isInCloud.boolValue,
        !requestOptions.isNetworkAccessAllowed {
        if self.cancelledRequestIDs.contains(requestID) {
          self.cancelledRequestIDs.remove(requestID)
          completeBlock(nil, [PHImageCancelledKey: NSNumber(value: 1)])
          return
        }

        guard let requestCloudOptions = requestOptions.copy() as? PHVideoRequestOptions else {
          assertionFailure("Expect PHImageRequestOptions")
          completeBlock(nil, nil)
          return
        }

        requestCloudOptions.isNetworkAccessAllowed = true

        self.fetchAVAsset(
          for: asset,
          options: requestCloudOptions,
          oldRequestID: requestID,
          completeBlock: completeBlock
        )
      } else {
        completeBlock(avAsset, info)
      }
    }

    self.update(requestID: requestID, with: imageRequestID, old: oldRequestID)
    return requestID
  }

  func startCachingAssets(
    for assets: [PHAsset],
    targetSize: CGSize,
    contentMode: PHImageContentMode,
    options: PHImageRequestOptions?) {
    self.manager.startCachingImages(
      for: assets,
      targetSize: targetSize,
      contentMode: contentMode,
      options: options
    )
  }

  func stopCachingAssets(
    for assets: [PHAsset],
    targetSize: CGSize,
    contentMode: PHImageContentMode,
    options: PHImageRequestOptions?) {
    self.manager.stopCachingImages(
      for: assets,
      targetSize: targetSize,
      contentMode: contentMode,
      options: options
    )
  }

  func stopCachingForAllAssets() {
    self.manager.stopCachingImagesForAllAssets()
  }
}
