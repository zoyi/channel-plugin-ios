//
//  SDWebImageSource.swift
//  ChannelIO
//
//  Created by Haeun Chung on 29/03/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import SDWebImage

public class SDWebImageSource: NSObject, InputSource {
  public var url: URL
  public var placeholder: UIImage?
  
  public init(url: URL, placeholder: UIImage? = nil) {
    self.url = url
    self.placeholder = placeholder
    super.init()
  }
  
  public init?(urlString: String, placeholder: UIImage? = nil) {
    if let validUrl = URL(string: urlString) {
      self.url = validUrl
      self.placeholder = placeholder
      super.init()
    } else {
      return nil
    }
  }
  
  public func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
    imageView.sd_setImage(with: self.url, completed: { [weak self] (image, error, cacheType, url) in
      if let image = image {
        callback(image)
      } else {
        callback(self?.placeholder)
      }
    })
  }
}
