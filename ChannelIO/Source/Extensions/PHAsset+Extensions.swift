//
//  PHAsset+Extensions.swift
//  ChannelIO
//
//  Created by R3alFr3e on 3/28/19.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Photos

extension PHAsset {
  private struct FetchKeys {
    fileprivate static var requestIDs: UInt8 = 0
    fileprivate static var fullScreenImage: UInt8 = 0
  }

  private var requestIDs: NSMutableArray? {
    get { return getAssociatedObject(key: &FetchKeys.requestIDs) as? NSMutableArray }
    set { setAssociatedObject(key: &FetchKeys.requestIDs, value: newValue) }
  }

  private(set) var fullScreenImage: (image: UIImage?, info: [AnyHashable: Any]?)? {
    get { return getAssociatedObject(key: &FetchKeys.fullScreenImage) as? (image: UIImage?, info: [AnyHashable: Any]?) }
    set { setAssociatedObject(key: &FetchKeys.fullScreenImage, value: newValue) }
  }

  internal func setAssociatedObject(
    key: UnsafePointer<UInt8>,
    value: Any?,
    policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN) {
    objc_setAssociatedObject(self, key, value, policy)
  }

  internal func getAssociatedObject(key: UnsafePointer<UInt8>) -> Any? {
    return objc_getAssociatedObject(self, key)
  }

  private func add(requestID: ImageRequestId) {
    objc_sync_enter(self)
    defer { objc_sync_exit(self) }

    var requestIDs: NSMutableArray! = self.requestIDs
    if requestIDs == nil {
        requestIDs = NSMutableArray()
        self.requestIDs = requestIDs
    }

    requestIDs.add(requestID)
  }

  @objc func cancelRequests() {
    objc_sync_enter(self)
    defer { objc_sync_exit(self) }

    if let requestIDs = self.requestIDs as? [ImageRequestId] {
      AssetManager.shared.cancelRequests(requestIDs: requestIDs)
      self.requestIDs?.removeAllObjects()
    }
  }

  @objc func fetchOriginalImage(
    options: PHImageRequestOptions? = nil,
    completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
    self.add(requestID: AssetManager.shared
      .fetchImageData(
        for: self,
        options: options,
        completeBlock: { data, info in
          var image: UIImage?
          if let data = data {
              image = UIImage(data: data)
          }
          completeBlock(image, info)
        }
      ))
    }

  @objc func fetchImageData(
    options: PHImageRequestOptions? = nil,
    completeBlock: @escaping (_ imageData: Data?, _ info: [AnyHashable: Any]?) -> Void) {
    self.add(requestID: AssetManager.shared
      .fetchImageData(
        for: self,
        options: options,
        completeBlock: completeBlock
      )
    )
  }

  @objc func fetchAVAsset(
    options: PHVideoRequestOptions? = nil,
    completeBlock: @escaping (_ AVAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) {
    self.add(requestID: AssetManager.shared
      .fetchAVAsset(
        for: self,
        options: options,
        completeBlock: completeBlock
      )
    )
  }
}
