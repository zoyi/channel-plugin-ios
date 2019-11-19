//
//  MessageViewController.swift
//  MessageView
//
//  Created by Ryan Nystrom on 12/22/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit

@objc public protocol CHMessageViewControllerDelegate: class {
//  @objc optional func textDidChange(text: String)
//  @objc optional func didPressSend(text: String)
}

class CHMessageViewController: UIViewController {
  public let messageView = CHMessageView()
  public var accessoryView: UIView?

  public var cacheKey: String?
  public var isAccessoryViewVisible: Bool = false

  private var keyboardWasVisible = false

  override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    commonInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    layout()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    //temporary disabled darkmode
    if #available(iOS 13.0, *) {
      self.overrideUserInterfaceStyle = .light
    }
    view.addSubview(messageView)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    cache()
    self.keyboardWasVisible = messageView.textView.isFirstResponder
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  // MARK: Public API

  final func setup(scrollView: UIScrollView) {
    self.scrollView = scrollView
    self.scrollView?.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)

    if scrollView.superview != view {
        view.addSubview(scrollView)
    }
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(gesture:)))
    scrollView.addGestureRecognizer(tapGesture)
    scrollView.panGestureRecognizer.addTarget(self, action: #selector(onPan(gesture:)))
    scrollView.keyboardDismissMode = .none
  }

  func setup(accessoryView: UIView) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    self.accessoryView?.removeFromSuperview()
    self.accessoryView = accessoryView
    accessoryView.isHidden = true
    self.view.addSubview(accessoryView)
    CATransaction.commit()
  }

  func removeAccessoryView() {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    self.isAccessoryViewVisible = false
    self.accessoryView?.removeFromSuperview()
    self.accessoryView = nil
    self.layout()
    CATransaction.commit()
  }

  @discardableResult
  func showAccessoryView(completion: (() -> Void)? = nil) -> Bool {
    guard self.accessoryView != nil else { return false }
    self.keyboardWasVisible = self.messageView.textView.isFirstResponder
    _ = self.messageView.resignResponder(animated: !self.keyboardWasVisible)
    self.isAccessoryViewVisible = true
    
    self.accessoryView?.frame = CGRect(
      x: 0,
      y: view.bounds.maxY,
      width: view.bounds.size.width,
      height: 0
    )

    self.accessoryView?.isHidden = false
    if !self.keyboardWasVisible {
      UIView.animate(withDuration: 0.4, animations: {
        self.layout()
      })
    } else {
      self.layout()
    }

    return true
  }

  @discardableResult
  func hideAccessoryView(completion: (() -> Void)? = nil) -> Bool {
    if self.keyboardWasVisible {
      _ = self.messageView.becomeResponder(animated: false)
    }
    self.isAccessoryViewVisible = false

    if !self.keyboardWasVisible {
      UIView.animate(withDuration: 0.4, animations: {
        self.layout()
      }, completion: { _ in
        self.accessoryView?.isHidden = true
        completion?()
      })
    } else {
      self.layout()
      completion?()
    }

    return true
  }

//  var borderColor: UIColor? {
//    get { return messageAutocompleteController.borderColor }
//    set {
//      messageAutocompleteController.borderColor = newValue
//      messageView.topBorderLayer.backgroundColor = newValue?.cgColor
//    }
//  }

  func setMessageView(hidden: Bool, animated: Bool) {
    isMessageViewHidden = hidden
    UIView.animate(withDuration: animated ? 0.25 : 0) {
      self.layout()
    }
  }

  open func didLayout() { }

  // MARK: Private API

  // keyboard management
  internal enum KeyboardState {
    case visible
    case resigned
    case showing
    case hiding
  }

  internal var keyboardState: KeyboardState = .resigned
  internal var scrollView: UIScrollView?
  internal var currentKeyboardHeight: CGFloat = 0
  internal var isMessageViewHidden = false
  internal var bottomMargin: CGFloat = 0.0

  internal func commonInit() {
    messageView.delegate = self
    
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(appWillResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
  }

  internal var safeAreaAdditionalHeight: CGFloat {
    switch keyboardState {
    case .showing, .visible: return 0
    case .hiding, .resigned: return view.util_safeAreaInsets.bottom
    }
  }

  internal func layout(updateOffset: Bool = false) {
    guard let scrollView = self.scrollView else { return }

    let bounds = view.bounds
    let keyboardHeight = self.currentKeyboardHeight

    let safeAreaAdditionalHeight = self.safeAreaAdditionalHeight
    let messageViewHeight = messageView.height
    let hiddenHeight = isMessageViewHidden ? messageViewHeight : 0

    let margin = self.isAccessoryViewVisible ?
      keyboardHeight + safeAreaAdditionalHeight :
      self.currentKeyboardHeight + safeAreaAdditionalHeight

    let messageViewFrame = CGRect(
        x: bounds.minX,
        y: bounds.minY + bounds.height - messageViewHeight - margin + hiddenHeight,
        width: bounds.width,
        height: messageViewHeight
    )
    messageView.frame = messageViewFrame

    // required for the nested UITextView to layout its internals correctly
    messageView.layoutIfNeeded()

    accessoryView?.frame = CGRect(
      x: bounds.minX,
      y: self.isAccessoryViewVisible ? messageViewFrame.maxY : bounds.height,
      width: bounds.width,
      height: keyboardHeight
    )

    let originalOffset = scrollView.contentOffset
    let heightChange = scrollView.frame.height - messageViewFrame.minY

    scrollView.frame = CGRect(
      x: bounds.minX,
      y: bounds.minY,
      width: bounds.width,
      height: messageView.isHidden ?
        bounds.height - self.bottomMargin - safeAreaAdditionalHeight :
        messageViewFrame.minY
    )

    if updateOffset, heightChange != 0 {
      let y = max(originalOffset.y + heightChange, -scrollView.util_adjustedContentInset.top)
      scrollView.contentOffset = CGPoint(x: originalOffset.x, y: y)
    }

    didLayout()
  }

  internal var fullCacheKey: String? {
    guard let key = cacheKey else { return nil }
    return "com.zoyi.channel.messageView.\(key)"
  }

  internal func cache() {
    guard let key = fullCacheKey else { return }
    let text = messageView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    let defaults = UserDefaults.standard
    if text.isEmpty {
        defaults.removeObject(forKey: key)
    } else {
        defaults.set(text, forKey: key)
    }
  }

  var cachedText: String? {
    guard let key = fullCacheKey else { return nil }
    return UserDefaults.standard.string(forKey: key)
  }

  func hideKeyboard() {
    self.keyboardWasVisible = false
    //self.currentKeyboardHeight = 0
    self.messageView.resignResponder()
  }

  func showKeyboard() {
    self.messageView.becomeResponder()
  }

  // MARK: Notifications

  @objc internal func keyboardWillShow(notification: Notification) {
    guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

    scrollView?.stopScrolling()
    self.removeAccessoryView()
    keyboardState = .showing

    currentKeyboardHeight = keyboardFrame.height
    messageView.heightOffset = currentKeyboardHeight + (scrollView?.util_safeAreaInsets.top ?? 0)

    UIView.animate(withDuration: animationDuration) { [weak self] in
      self?.layout()
    }
  }

  @objc internal func keyboardDidShow(notification: Notification) {
    keyboardState = .visible
  }

  @objc internal func keyboardWillHide(notification: Notification) {
    guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

    if self.forceTextInputbarAdjustment(for: self.view.window?.firstResponder) {
      return
    }

    keyboardState = .hiding
    currentKeyboardHeight = 0

    UIView.animate(withDuration: animationDuration) {
      self.layout()
    }
  }

  public func forceTextInputbarAdjustment(for responder: UIResponder?) -> Bool {
    return false
  }

  public func setBottomMargin(point: CGFloat) {
    self.bottomMargin = point
  }

  @objc internal func keyboardDidHide(notification: Notification) {
    UIView.setAnimationsEnabled(true)
    keyboardState = .resigned
  }

  @objc internal func appWillResignActive(notification: Notification) {
    cache()
  }

  // MARK: Gestures

  @objc func onTap(gesture: UIPanGestureRecognizer) {
    _ = messageView.resignResponder()
  }

  @objc func onPan(gesture: UIPanGestureRecognizer) {
    guard gesture.state == .changed else { return }
    let location = gesture.location(in: view)
    if messageView.frame.contains(location) {
      _ = messageView.resignResponder()
    }
  }
}
