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
  
  func pushChat(with chatId: String?, from view: UIViewController?) {
    let pluginSignal = CHPlugin.get(with: mainStore.state.plugin.id)
    let supportSignal =  CHSupportBot.get(with: mainStore.state.plugin.id, fetch: chatId == nil)
   
    let chatView = UserChatViewController()
    if let userChatId = chatId {
      chatView.userChatId = userChatId
    }
    
    Observable.zip(pluginSignal, supportSignal)
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        let reloadMessage = CHAssets.localized("plugin.reload.message")
        SVProgressHUD.show(withStatus: reloadMessage)
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (plugin, entry) in
        if entry.step != nil && entry.supportBot != nil {
          mainStore.dispatch(GetSupportBotEntry(bot: plugin.1, entry: entry))
        }
        SVProgressHUD.dismiss()
        
        view?.navigationController?.pushViewController(chatView, animated: true)
      }, onError: { (error) in
        SVProgressHUD.dismiss()
      }).disposed(by: self.disposeBag)
  }
  
  func pushChatList(from view: UIViewController?) {
    let viewController = UserChatsViewController()
    view?.navigationController?.pushViewController(viewController, animated: true)
  }
  
  func pushSettings(from view: UIViewController?) {
    let settingView = SettingRouter.createModule()
    view?.navigationController?.pushViewController(settingView, animated: true)
  }
  
  func presentEamilComposer(from view: UIViewController?) {
    guard MFMailComposeViewController.canSendMail() else { return }
    
    let mailComposerVC = MFMailComposeViewController()
    mailComposerVC.mailComposeDelegate = self
    view?.present(mailComposerVC, animated: true, completion: nil)
  }
  
  static func createModule(with chatId: String? = nil) -> LoungeView {
    let view = LoungeView()
    let presenter = LoungePresenter()
    let interactor = LoungeInteractor()
    let router = LoungeRouter()
    
    view.presenter = presenter
    
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
