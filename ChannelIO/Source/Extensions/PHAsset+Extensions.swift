//
//  PHAsset+Extensions.swift
//  ChannelIO
//
//  Created by R3alFr3e on 3/28/19.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {
  func fetchImage(size: CGSize? = nil, options: PHImageRequestOptions? = nil, completion: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
    let screenSize = size ?? UIScreen.main.bounds.size
    
    let imageOption = options ?? PHImageRequestOptions()
    imageOption.deliveryMode = .highQualityFormat
    //imageOption.resizeMode = .exact
    
    PHImageManager.default().requestImage(
      for: self,
      targetSize: screenSize,
      contentMode: .aspectFit, options: imageOption) { (image, info) in
        completion(image, info)
      }
  }
  
  func fetchImageData(options: PHImageRequestOptions? = nil, completion: @escaping (Data?, String?, UIImage.Orientation, [AnyHashable:Any]?) -> Void) {
    let options = options ?? PHImageRequestOptions()
    //options.deliveryMode = .highQualityFormat
    //options.resizeMode = .exact
    
    PHImageManager.default().requestImageData(
      for: self,
      options: options) { (data, dataUTI, orientation, info) in
        completion(data, dataUTI, orientation, info)
      }
  }
  
  func fetchVideo(completion: @escaping (AVAsset?, AVAudioMix?, [AnyHashable: Any]?) -> Void) {
    let options = PHVideoRequestOptions()
    
    PHImageManager.default().requestAVAsset(
      forVideo: self,
      options: options) { (asset, mix, info) in
        completion(asset, mix, info)
      }
  }
}
