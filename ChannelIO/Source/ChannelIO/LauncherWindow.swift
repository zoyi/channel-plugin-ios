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
    super.init(frame: UIScreen.main.bounds)
    self.initWindowSettings()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  internal override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    if let popupView = self.inAppNotificationView as? PopupInAppNotificationView,
      popupView.alpha != 0 {
      let popupPoint = convert(point, to: popupView)
      return popupView.point(inside: popupPoint, with: event)
    }
    
    if let bannerView = self.inAppNotificationView as? BannerInAppNotificationView,
      bannerView.alpha != 0 {
      let bannerPoint = convert(point, to: bannerView)
      return bannerView.point(inside: bannerPoint, with: event)
    }
    
    if let launchView = self.launcherView, launchView.alpha != 0 {
      let launchViewPoint = convert(point, to: launchView)
      return launchView.point(inside: launchViewPoint, with: event)
    }
    
    return false
  }
  
  override func makeKey() {
  }
  
  private func initWindowSettings() {
    self.rootViewController = UIViewController()
    self.window?.backgroundColor = nil
    self.window?.isHidden = false
    self.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
    self.makeKeyAndVisible()
  }
  
  func addCustomView(with view: UIView) {
    self.rootViewController?.view.addSubview(view)
    if let view = view as? LauncherView {
      view.layer.zPosition = 1
    }
  }
}
