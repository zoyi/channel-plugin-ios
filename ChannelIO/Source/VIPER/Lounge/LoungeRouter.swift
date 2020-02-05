//
//  LoungeRouter.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import SVProgressHUD
import MessageUI

class LoungeRouter: NSObject, LoungeRouterProtocol {
  var disposeBag = DisposeBag()
  
  func pushChat(with chatId: String?, animated: Bool, from view: UIViewController?) {
    let controller = UserChatRouter.createModule(userChatId: chatId)
    view?.navigationController?.pushViewController(controller, animated: animated)
  }
  
  func pushChatList(from view: UIViewController?) {
    let viewController = UserChatsViewController()
    view?.navigationController?.pushViewController(viewController, animated: true)
  }
  
  func pushSettings(from view: UIViewController?) {
    let settingView = SettingRouter.createModule()
    view?.navigationController?.pushViewController(settingView, animated: true)
  }

  func presentBusinessHours(from view: UIViewController?) {
    let channel = mainStore.state.channel
    let alertController = UIAlertController(
      title: CHAssets.localized("ch.business_hours"),
      message: channel.workingTimeString,
      preferredStyle: .alert)
    
    alertController.addAction(UIAlertAction(title: CHAssets.localized("ch.button_confirm"), style: .default) {  _ in
      alertController.dismiss(animated: true, completion: nil)
    })
    alertController.modalTransitionStyle = .crossDissolve
    view?.present(alertController, animated: true, completion: nil)
  }
  
  func presentExternalSource(
    with source: LoungeExternalSourceModel,
    from view: UIViewController?) {
    switch source.type {
    case .email:
      guard MFMailComposeViewController.canSendMail() else { return }
      
      let mailComposerVC = MFMailComposeViewController()
      mailComposerVC.mailComposeDelegate = self
      view?.present(mailComposerVC, animated: true, completion: nil)
    case .phone:
      if let url = URL(string:source.value) {
        UIApplication.shared.open(url)
      }
    case .link:
      UIPasteboard.general.string = source.value
      CHNotification.shared.display(
        message: CHAssets.localized("ch.integrations.copy_link.success")
      )
      CHNotification.shared.display(
        message: CHAssets.localized("ch.common_error"),
        config: .warningConfig
      )
    default:
      SVProgressHUD.show()
      CHAppMessenger
        .getUri(with: source.value)
        .retry(.delayed(maxCount: 3, time: 3.0))
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (result) in
          guard let uri = result.uri, let url = URL(string: uri) else {
            CHNotification.shared.display(
              message: CHAssets.localized("ch.common_error"),
              config: .warningConfig
            )
            SVProgressHUD.dismiss()
            return
          }
          SVProgressHUD.dismiss()
          UIApplication.shared.open(url)
        }, onError: { (_) in
          SVProgressHUD.dismiss()
          CHNotification.shared.display(
            message: CHAssets.localized("ch.common_error"),
            config: .warningConfig
          )
        }).disposed(by: self.disposeBag)
    }
  }
  
  static func createModule(with chatId: String? = nil) -> LoungeView {
    let view = LoungeView()
    let presenter = LoungePresenter()
    let interactor = LoungeInteractor()
    let router = LoungeRouter()
    
    view.presenter = presenter
    view.mainView.presenter = presenter
    
    presenter.view = view
    presenter.interactor = interactor
    presenter.router = router
    presenter.chatId = chatId
    
    interactor.presenter = presenter
    return view
  }
}

extension LoungeRouter: MFMailComposeViewControllerDelegate {
  func mailComposeController(
    _ controller: MFMailComposeViewController,
    didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true, completion: nil)
  }
}
