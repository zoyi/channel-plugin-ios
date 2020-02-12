//
//  LauncherWindow.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/11.
//

final class LauncherWindow: UIWindow {
  var launcherView: LauncherView?
  var inAppNotificationView: InAppNotification?

  private weak var hostKeyWindow: UIWindow?
  
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
    self.hostKeyWindow = CHUtils.getKeyWindow()
    self.initWindowSettings()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  internal override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    var result: Bool = false
    
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
    //NOTE: we don't want this window to be key window
    self.hostKeyWindow?.makeKey()
  }
  
  func insertView(with view: UIView, animated: Bool) {
    guard let rootView = self.rootViewController?.view else { return }
    
    view.insert(on: rootView, animated: animated)
  }
  
  func updateStatusBarAppearance() {
    self.rootViewController?.setNeedsStatusBarAppearanceUpdate()
  }
}
