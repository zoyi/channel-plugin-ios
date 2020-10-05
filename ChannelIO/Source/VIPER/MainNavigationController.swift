//
//  MainNavigationController.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 14..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
//import RxSwift
//import RxCocoa

protocol CHNavigationDelegate: class {
  func willPopViewController(willShow controller:UIViewController)
  //func willPushViewController()
}

class MainNavigationController: BaseNavigationController {
  let disposeBag = _RXSwift_DisposeBag()
  
  // MARK: Properties
  weak var chDelegate: CHNavigationDelegate? = nil
  var isPushingViewController = false
  
  var currentBgColor: UIColor?
  var currentGradientColor: UIColor?

  var useDefault = false {
    didSet {
      if useDefault {
        self.navigationBar.barTintColor = nil
        self.navigationBar.titleTextAttributes =  [.foregroundColor: mainStore.state.plugin.textUIColor]
        self.navigationBar.isTranslucent = false
        self.setNeedsStatusBarAppearanceUpdate()
      }
    }
  }
  
  deinit {
    dlog("[ChannelIO]: deinit navigation")
  }
  
  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
    self.interactivePopGestureRecognizer?.delegate = self
    self.navigationBar.isTranslucent = false
    self.navigationBar.barStyle = .black

    if #available(iOS 13, *) {
      self.presentationController?.delegate = self
    }
    
    self.navigationBar.rx.observeWeakly(CGRect.self, "frame")
      .observeOn(_RXSwift_MainScheduler.instance)
      .subscribe(onNext: { [weak self] (frame) in
        guard let self = self else { return }
        let plugin = mainStore.state.plugin
        let bgColor = UIColor(plugin.color) ?? UIColor.white
        let gradientColor = UIColor(plugin.gradientColor) ?? UIColor.white

        self.navigationBar.setGradientBackground(
          colors: [bgColor, bgColor, bgColor, gradientColor],
          startPoint: .topLeft,
          endPoint: .topRight
        )
      }).disposed(by: self.disposeBag)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    mainStore.subscribe(self) {
      $0.select { (state: AppState) in
        state.plugin
      }.skipRepeats { $0 == $1 }
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    mainStore.unsubscribe(self)
  }

  override var prefersStatusBarHidden: Bool {
    return false
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return mainStore.state.plugin.textColor == "white" ? .lightContent : .default
  }
  
  override var shouldAutorotate: Bool {
    return false
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.portrait
  }
}

// MARK: - StoreSubscriber

extension MainNavigationController: ReSwift_StoreSubscriber {
  func newState(state: CHPlugin) {
    if !self.useDefault {
      // Bar Color
      self.navigationBar.setValue(true, forKey: "hidesShadow")
      self.navigationBar.tintColor = state.textUIColor
      
      self.navigationBar.setGradientBackground(
        colors: state.gradientColors,
        startPoint: .left,
        endPoint: .right
      )
      
      // Title
      if self.title == nil || self.title == "" {
        self.navigationBar.topItem?.title = state.name
      }
      
      // Title Color
      self.navigationBar.titleTextAttributes = [.foregroundColor: state.textUIColor]
      self.setNeedsStatusBarAppearanceUpdate()
    }
  }
}

extension MainNavigationController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard gestureRecognizer is UIScreenEdgePanGestureRecognizer else { return true }
    return viewControllers.count > 1 && !isPushingViewController
  }
  
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return false
  }
}

extension MainNavigationController : UINavigationControllerDelegate {
  func navigationController(
    _ navigationController: UINavigationController,
    didShow viewController: UIViewController, animated: Bool) {
    isPushingViewController = false
  }
  
  func navigationController(
    _ navigationController: UINavigationController,
    willShow viewController: UIViewController,
    animated: Bool) {
    if let coordinator = navigationController.topViewController?.transitionCoordinator {
      coordinator.notifyWhenInteractionChanges { (context) in
        if !context.isCancelled {
          self.chDelegate?.willPopViewController(willShow: viewController)
        }
      }
    }
  }
}

@available(iOS 13, *)
extension MainNavigationController : UIAdaptivePresentationControllerDelegate {
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    ChannelIO.delegate?.willHideMessenger?()
    ChannelIO.delegate?.onHideMessenger?()
    ChannelIO.didDismiss()
  }
}
