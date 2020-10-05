//
//  TLBundle.swift
//  Pods
//
//  Created by wade.hawk on 2017. 5. 9..
//
//

import Foundation

class TLBundle {
    class func podBundleImage(named: String) -> UIImage? {
      return CHAssets.getImage(named: named)
//        let podBundle = Bundle(for: ChannelIO.self)
//        if let url = podBundle.url(forResource: "TLPhotoPickerController", withExtension: "bundle") {
//            let bundle = Bundle(url: url)
//            return UIImage(named: named, in: bundle, compatibleWith: nil)!
//        }
//        return nil
    }
    
    class func bundle() -> Bundle {
//        let podBundle = Bundle(for: ChannelIO.self)
//        if let url = podBundle.url(forResource: "TLPhotoPicker", withExtension: "bundle") {
//            let bundle = Bundle(url: url)
//            return bundle ?? podBundle
//        }
      return CHAssets.getBundle()
    }
}
