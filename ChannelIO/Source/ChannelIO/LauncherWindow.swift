//
//  LauncherWindow.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/11.
//

final class LauncherWindow: UIWindow {
  var launcherView: LauncherView?
  var inAppNotificationView: InAppNotification?

  init() {
    let defaultSize = UIScreen.main.bounds.size
    var y = UIApplication.shared.statusBarFrame.height
    
    var bounds = CGRect(
      x: 0, y: y,
      width: defaultSize.width,
      height: defaultSize.height - y
    )
    
    if let viewController = CHUtils.getTopController() {
      y += viewController.navigationController?.navigationBar.bounds.height ?? 0
      bounds = CGRect(
        x: 0, y: y,
        width: viewController.view.frame.width,
        height: viewController.view.frame.height
      )
    }
    
    super.init(frame: bounds)
    self.initWindowSettings()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  internal override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    var result: Bool = false
    
    if let popupView = self.inAppNotificationView as? PopupInAppNotificationView,
      popupView.alpha != 0 {
      let popupPoint = convert(point, to: popupView)
      result = result || popupView.point(inside: popupPoint, with: event)
    }
    
    if let bannerView = self.inAppNotificationView as? BannerInAppNotificationView,
      bannerView.alpha != 0 {
      let bannerPoint = convert(point, to: bannerView)
      result = result || bannerView.point(inside: bannerPoint, with: event)
    }
    
    if let launchView = self.launcherView, launchView.alpha != 0 {
      let launchViewPoint = convert(point, to: launchView)
      result = result || launchView.point(inside: launchViewPoint, with: event)
    }
    
    return result
  }
  
  override func makeKey() {}
  
  private func initWindowSettings() {
    self.rootViewController = UIViewController()
    self.window?.backgroundColor = nil
    self.window?.isHidden = false
    self.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
    self.makeKeyAndVisible()
  }
  
  func addCustomView(with view: UIView) {
    self.rootViewController?.view.addSubview(view)
    if let view = view as? PopupInAppNotificationView {
      view.layer.zPosition = 1
    } else if let view = view as? BannerInAppNotificationView {
      view.layer.zPosition = 1
    }
  }
  
  func updateStatusBarAppearance() {
    self.rootViewController?.setNeedsStatusBarAppearanceUpdate()
  }
}
