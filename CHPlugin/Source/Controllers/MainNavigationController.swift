//
//  MainNavigationController.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 14..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import ReSwift

protocol CHNavigationDelegate {
  func willPopViewController()
  //func willPushViewController()
}

class MainNavigationController: BaseNavigationController {

  // MARK: Properties
  var chDelegate: CHNavigationDelegate? = nil
  var statusBarStyle = UIStatusBarStyle.default

  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
    self.navigationBar.isTranslucent = false
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    mainStore.subscribe(self)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    mainStore.unsubscribe(self)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return self.statusBarStyle
  }
}


// MARK: - StoreSubscriber

extension MainNavigationController: StoreSubscriber {

  func newState(state: AppState) {
    // Bar Color
    self.navigationBar.barTintColor = UIColor(state.plugin.color)
    self.navigationBar.tintColor = state.plugin.textUIColor

    // Title
    if self.title == nil || self.title == "" {
      self.navigationBar.topItem?.title = state.channel.name
    }
    
    // Title Color
    let titleColor = state.plugin.textColor == "white" ? UIColor.white : UIColor.black
    self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: titleColor]

    // Status bar color
    self.statusBarStyle = state.plugin.textColor == "white" ? .lightContent : .default
    self.setNeedsStatusBarAppearanceUpdate()
  }

}

extension MainNavigationController : UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController,
                            willShow viewController: UIViewController,
                            animated: Bool) {
    if let coordinator = navigationController.topViewController?.transitionCoordinator {
      coordinator.notifyWhenInteractionEnds({ (context) in
        if !context.isCancelled {
          self.chDelegate?.willPopViewController()
        }
      })
    }
  }
}
