//
//  UserChatRouter.swift
//  CHPlugin
//
//  Created by Haeun Chung on 27/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit
//import RxSwift
import Photos
import MobileCoreServices
import AVKit

class UserChatRouter: NSObject, UserChatRouterProtocol {
  private var assetsSubject = _RXSwift_PublishSubject<[PHAsset]>()
  private var viewerTransitionDelegate: ZoomAnimatedTransitioningDelegate? = nil
  
  static func createModule(
    userChatId: String?,
    text: String?,
    isOpenChat: Bool = false
  ) -> UserChatView {
    let view = UserChatView()
    
    let presenter = UserChatPresenter()
    let interactor = UserChatInteractor()
    interactor.presenter = presenter
    
    presenter.router = UserChatRouter()
    presenter.interactor = interactor
    presenter.view = view
    presenter.userChatId = userChatId
    presenter.preloadText = text
    presenter.isOpenChat = isOpenChat
    
    view.presenter = presenter
    return view
  }
  
  func presentImageViewer(
    with url: URL?,
    photoUrls: [URL],
    imageView: UIImageView,
    from view: UIViewController?) {
    let viewer = FullScreenSlideshowViewController()
    viewer.slideshow.circular = false
    viewer.slideshow.pageIndicator = LabelPageIndicator(
      frame: CGRect(x:0,y:0, width: UIScreen.main.bounds.width, height: 60))
    viewer.slideshow.pageIndicatorPosition = PageIndicatorPosition(
      horizontal: .center,
      vertical: .customTop(padding: 5))
    viewer.inputs = photoUrls.map { (url) -> SDWebImageSource in
      return SDWebImageSource(url: url)
    }
    viewer.downloadClicked = { index in
      self.processSaveFile(url: photoUrls[index], from: viewer)
    }

    if let url = url, let index = photoUrls.firstIndex(of: url) {
      viewer.initialPage = index
      self.viewerTransitionDelegate = ZoomAnimatedTransitioningDelegate(
        imageView: imageView,
        slideshowController: viewer)
      viewer.transitioningDelegate = self.viewerTransitionDelegate
      viewer.slideshow.currentPageChanged = { [weak self] page in
        self?.viewerTransitionDelegate?.referenceImageView = page != index ?
          nil : imageView
      }
    }
    
    viewer.modalPresentationStyle = .currentContext
    view?.present(viewer, animated: true, completion: nil)
  }
  
  private func processSaveFile(url: URL, from view: UIViewController?) {
    if #available(iOS 11.0, *), let data = try? Data(contentsOf: url) {
      let controller = UIActivityViewController(
        activityItems: [data],
        applicationActivities: nil
      )
      view?.present(controller, animated: true, completion: nil)
    } else {
      CHNotification.shared.display(
        message: CHAssets.localized("ch.error.description"),
        config: CHNotificationConfiguration.warningNormalConfig
      )
    }
  }
  
  func presentVideoPlayer(with url: URL?, from view: UIViewController?) {
    guard let url = url else { return }
    
    let moviePlayer = AVPlayerViewController()
    let player = AVPlayer(url: url)
    moviePlayer.player = player
    moviePlayer.modalPresentationStyle = .overFullScreen
    moviePlayer.modalTransitionStyle = .crossDissolve
    view?.present(moviePlayer, animated: true, completion: nil)
  }

  func showNewChat(with text: String, from view: UINavigationController?) {
    view?.popViewController(animated: true, completion: {
      let controller = UserChatRouter.createModule(userChatId: nil, text: text)
      view?.pushViewController(controller, animated: true)
    })
  }
  
  func showOptionActionSheet(from view: UIViewController?) -> _RXSwift_PublishSubject<[PHAsset]> {
    self.assetsSubject = _RXSwift_PublishSubject<[PHAsset]>()
    
    let alertView = UIAlertController(
      title:nil,
      message:nil,
      preferredStyle: .actionSheet
    )
    
    alertView.addAction(
      UIAlertAction(
        title: CHAssets.localized("ch.camera"),
        style: .default) { [weak self] _ in
          self?.checkCameraPermission() { [weak self] in
            self?.checkPhotoLibraryPermission() { [weak self] in
              dispatch {
                self?.presentCameraPicker(from: view)
              }
            }
          }
      }
    )
    alertView.addAction(
      UIAlertAction(
        title: CHAssets.localized("ch.photo.album"),
        style: .default
      ) { [weak self] _ in
        self?.checkPhotoLibraryPermission() { [weak self] in
          self?.presentPhotoPicker(from: view)
        }
      }
    )
    alertView.addAction(
      UIAlertAction(
        title: CHAssets.localized("ch.chat.resend.cancel"),
        style: .cancel
      )
    )
    
    if UIDevice.current.userInterfaceIdiom == .pad {
      if let popoverController = alertView.popoverPresentationController, let view = view {
        popoverController.sourceView = view.view
        popoverController.sourceRect = CGRect(
          x: view.view.bounds.midX,
          y: view.view.bounds.midY,
          width: 0,
          height: 0
        )
        popoverController.permittedArrowDirections = []
      }
    }
    
    CHUtils.getTopNavigation()?.present(alertView, animated: true, completion: nil)
    return self.assetsSubject
  }
  
  private func checkPhotoLibraryPermission(completion: (() -> Void)? = nil) {
    dispatch {
      let status = PHPhotoLibrary.authorizationStatus()
      switch status {
      case .authorized: completion?()
      case .denied, .restricted :
        dispatch {
          self.showPermissionError()
        }
      case .notDetermined:
        PHPhotoLibrary.requestAuthorization { [weak self] status in
          guard let self = self else { return }
          switch status {
          case .authorized:
            completion?()
          case .denied, .restricted:
            dispatch {
              self.showPermissionError()
            }
          case .notDetermined: break
          default:
            break
          }
        }
      default:
        break
      }
    }
  }
  
  private func checkCameraPermission(completion: (() -> Void)? = nil) {
    dispatch {
      let status = AVCaptureDevice.authorizationStatus(for: .video)
      switch status {
      case .authorized: completion?()
      case .denied, .restricted :
        dispatch {
          self.showPermissionError()
        }
      case .notDetermined:
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
          guard let self = self else { return }
          guard granted else {
            dispatch {
              self.showPermissionError()
            }
            return
          }
          completion?()
        }
      default: break
      }
    }
  }
  
  private func showPermissionError() {
    dispatch {
      let permissionAlert = AlertViewController(
        title: nil,
        message: CHAssets.localized("ch.permission.denied"),
        type: .normal
      ).then {
        $0.addAction(
          AlertAction(title: CHAssets.localized("ch.button_confirm"), type: .normal, handler: { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          })
        )
      }
      
      self.assetsSubject.onError(ChannelError.init(msg: "permission denied"))
      CHUtils.getTopController()?.present(permissionAlert, animated: true, completion: nil)
    }
  }
  
  func showRetryActionSheet(from view: UIView?) -> _RXSwift_Observable<Bool?> {
    return _RXSwift_Observable.create { (subscriber) in
      let alertView = UIAlertController(
        title:nil,
        message:nil,
        preferredStyle: .actionSheet
      )
      alertView.addAction(
        UIAlertAction(
          title: CHAssets.localized("ch.chat.retry_sending_message"),
          style: .default) {  (_) in
          subscriber.onNext(true)
        }
      )
      alertView.addAction(
        UIAlertAction(
          title: CHAssets.localized("ch.chat.delete"),
          style: .destructive) {  (_) in
          subscriber.onNext(false)
        }
      )
      alertView.addAction(
        UIAlertAction(
          title: CHAssets.localized("ch.chat.resend.cancel"),
          style: .cancel) { (_) in
          subscriber.onNext(nil)
        }
      )
      
      CHUtils.getTopController()?.present(alertView, animated: true, completion: nil)
      return _RXSwift_Disposables.create()
    }
  }
}

extension UserChatRouter: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  private func presentPhotoPicker(
    max: Int = 20,
    from view: UIViewController?
  ) {
    dispatch {
      let viewController = TLPhotosPickerViewController(
        withPHAssets: { (assets) in
          self.assetsSubject.onNext(assets)
          self.assetsSubject.onCompleted()
        },
        didCancel: nil
      )
      
      var configure = TLPhotosPickerConfigure()
      configure.maxSelectedAssets = max
      viewController.configure = configure
      
      viewController.handleNoAlbumPermissions = { [weak self] picker in
        guard let self = self else { return }
        dispatch {
          picker.dismiss(animated: true, completion: { [weak self] in
            dispatch {
              self?.showPermissionError()
            }
          })
        }
        
      }
      
      viewController.handleNoCameraPermissions = { [weak self] picker in
        guard let self = self else { return }
        dispatch {
          picker.dismiss(animated: true, completion: { [weak self] in
            dispatch {
              self?.showPermissionError()
            }
          })
        }
      }
      
      view?.present(viewController, animated: true, completion: nil)
    }
  }
  
  private func presentCameraPicker(from view: UIViewController?) {
    dispatch {
      let controller = UIImagePickerController()
      controller.sourceType = .camera
      controller.allowsEditing = true
      controller.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
      controller.videoQuality = .typeMedium
      controller.videoMaximumDuration = 60

      controller.delegate = self
      view?.present(controller, animated: true, completion: nil)
    }
  }
  
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    var request: PHAssetChangeRequest? = nil
    
    var placeholderAsset: PHObjectPlaceholder? = nil
    PHPhotoLibrary.shared().performChanges({
      if let image = info[.originalImage] as? UIImage {
        request = PHAssetChangeRequest.creationRequestForAsset(from: image)
      } else if (info[.mediaType] as? String) == kUTTypeMovie as String {
        request = PHAssetChangeRequest.creationRequestForAssetFromVideo(
          atFileURL: info[.mediaURL] as! URL)
      }
      guard let newAssetRequest = request else { return }
      placeholderAsset = newAssetRequest.placeholderForCreatedAsset
    }, completionHandler: { [weak self] (sucess, error) in
      guard
        sucess,
        let identifier = placeholderAsset?.localIdentifier,
        let asset = PHAsset.fetchAssets(
          withLocalIdentifiers: [identifier],
          options: nil).firstObject else {
          if let error = error {
            self?.assetsSubject.onError(error)
          }
          return
        }
      
        dispatch {
          picker.dismiss(animated: true, completion: { [weak self] in
            self?.assetsSubject.onNext([asset])
            self?.assetsSubject.onCompleted()
          })
        }
      }
    )
  }
}

extension UserChatRouter : UIDocumentInteractionControllerDelegate {
  func pushFileView(with url: URL?, from view: UIViewController?) {
    guard let url = url, let view = view else { return }
    
    let docController = UIDocumentInteractionController(url: url)
    docController.delegate = self
    
    if !docController.presentPreview(animated: true) {
      docController.presentOptionsMenu(
        from: view.view.bounds, in: view.view, animated: true)
    }
  }
  
  func documentInteractionControllerViewControllerForPreview(
    _ controller: UIDocumentInteractionController) -> UIViewController {
    guard let controller = CHUtils.getTopController() else {
      return UIViewController()
    }
    
    return controller
  }
}
