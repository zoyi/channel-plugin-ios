//
//  UserChatRouter.swift
//  CHPlugin
//
//  Created by Haeun Chung on 27/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit
import RxSwift
import DKImagePickerController
import CHPhotoBrowser

class UserChatRouter: NSObject, UserChatRouterProtocol {
//  static func createModule(userChatId: String?) -> UserChatView {
//    let view = UserChatView()
//    return view
//  }
  func showImageViewer(with url: URL?, photoUrls: [URL], from view: UIViewController?, dataSource: MWPhotoBrowserDelegate) {
    guard let url = url else { return }
    let index = photoUrls.index { (photoUrl) -> Bool in
      return photoUrl.absoluteString == url.absoluteString
    }
    
    let browser = MWPhotoBrowser(delegate: dataSource)
    browser?.zoomPhotosToFill = false
    
    let navigation = MainNavigationController(rootViewController: browser!)
    if index != nil {
      browser?.setCurrentPhotoIndex(UInt(index!))
    }
    view?.present(navigation, animated: true, completion: nil)
  }
  
  func showOptionActionSheet(from view: UIViewController?) -> Observable<[DKAsset]> {
    return Observable.create({ (subscriber) in
      let alertView = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
      
      alertView.addAction(
        UIAlertAction(title: CHAssets.localized("ch.camera"), style: .default) { [weak self] _ in
          _ = self?.showOptionPicker(type: .camera, from: view).subscribe(onNext: { asset in
            subscriber.onNext(asset)
          })
      })
      
      alertView.addAction(
        UIAlertAction(title: CHAssets.localized("ch.photo.album"), style: .default) { [weak self] _ in
          _ = self?.showOptionPicker(type: .photo, max: 20, from: view).subscribe(onNext: { (assets) in
            subscriber.onNext(assets)
          })
      })
      
      alertView.addAction(
        UIAlertAction(title: CHAssets.localized("ch.chat.resend.cancel"), style: .cancel) { _ in
          //nothing
      })
      
      CHUtils.getTopNavigation()?.present(alertView, animated: true, completion: nil)
      return Disposables.create()
    })
   
  }
  
  func showOptionPicker(
    type: DKImagePickerControllerSourceType,
    max: Int = 0,
    assetType: DKImagePickerControllerAssetType = .allPhotos, from view: UIViewController?) -> Observable<[DKAsset]> {
    return Observable.create({ (subscriber) in
      let pickerController = DKImagePickerController()
      pickerController.sourceType = type
      pickerController.showsCancelButton = true
      pickerController.maxSelectableCount = max
      pickerController.assetType = assetType
      pickerController.didSelectAssets = { (assets: [DKAsset]) in
        subscriber.onNext(assets)
        subscriber.onCompleted()
      }
      
      view?.present(pickerController, animated: true, completion: nil)
      return Disposables.create()
    })
  }
  
  func showRetryActionSheet(from view: UIViewController?) -> Observable<Bool?> {
    return Observable.create({ (subscriber) in
      let alertView = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
      alertView.addAction(UIAlertAction(title: CHAssets.localized("ch.chat.retry_sending_message"), style: .default) {  _ in
        subscriber.onNext(true)
      })
      
      alertView.addAction(UIAlertAction(title: CHAssets.localized("ch.chat.delete"), style: .destructive) {  _ in
        subscriber.onNext(false)
      })
      
      alertView.addAction(UIAlertAction(title: CHAssets.localized("ch.chat.resend.cancel"), style: .cancel) { _ in
        subscriber.onNext(nil)
      })
      
      CHUtils.getTopController()?.present(alertView, animated: true, completion: nil)
      return Disposables.create()
    })
  }
}

