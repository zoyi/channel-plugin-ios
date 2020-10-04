//
//  MessageView.swift
//  MessageView
//
//  Created by Ryan Nystrom on 12/20/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit

enum MessageViewState {
  case normal
  case highlight
  case disabled
}

final class CHMessageView: UIView, MessageTextViewListener {
  let textContainerView = UIView()
  @objc let textView = CHMessageTextView().then {
    $0.isUserInteractionEnabled = false
  }

  var animatedTargetY: CGFloat {
    let toolbarHeight = self.toolbarView?.frame.height ?? 0
    let topAccessoryHeight = self.topAccessoryView?.frame.height ?? 0
    return self.textContainerView.frame.height
      - self.textView.frame.height
      - toolbarHeight
      - topAccessoryHeight
  }

  var emptyTextDisabledRightButton = true

  internal weak var delegate: CHMessageViewDelegate?
  internal var observation: NSKeyValueObservation?
  internal let leftButton = UIButton()
  internal let rightButton = UIButton()
  internal var state: MessageViewState = .normal

  internal let UITextViewContentSizeKeyPath = #keyPath(UITextView.contentSize)
  internal let topBorderLayer = CALayer()

  internal var toolbarView: UIView?
  internal var topAccessoryView: UIView?
  internal var bottomView: UIView?

  internal var rightButtonAction: Selector?
  internal var leftButtonInset: CGFloat = 0
  internal var rightButtonInset: CGFloat = 0
  internal var leftButtonSize: CGSize = .zero
  internal var rightButtonSize: CGSize = .zero
  internal var ignoreLineHeight = false
  internal var suppressKVO = false

  internal var placeholders: [MessageViewState: String] = [:]

  enum ButtonPosition {
    case left
    case right
  }

  enum ButtonVerticalPosition {
    case top
    case middle
    case bottom
  }

  var textViewBecomeActive: ((CHMessageView) -> Void)?

  internal var heightOffset: CGFloat = 0

  override internal init(frame: CGRect) {
    super.init(frame: frame)

    self.textContainerView.backgroundColor = .white
    self.textContainerView.addSubview(leftButton)
    self.textContainerView.addSubview(textView)
    self.textContainerView.addSubview(rightButton)
    self.textContainerView.layer.addSublayer(topBorderLayer)
    self.addSubview(self.textContainerView)

    //Set action button
    leftButton.imageEdgeInsets = .zero
    leftButton.titleEdgeInsets = .zero
    leftButton.contentEdgeInsets = .zero
    leftButton.titleLabel?.font = self.font ?? UIFont.systemFont(ofSize: 14)
    leftButton.imageView?.contentMode = .scaleAspectFit
    leftButton.imageView?.clipsToBounds = true

    // setup text view
    textView.contentInset = .zero
    textView.textContainerInset = .zero
    textView.backgroundColor = .clear
    //textView.addObserver(self, forKeyPath: UITextViewContentSizeKeyPath, options: [.new], context: nil)
    textView.font = self.font ?? UIFont.systemFont(ofSize: 14)
    textView.add(listener: self)
    textView.placeholderTextColor = UIColor.grey500

    // setup TextKit props to defaults
    textView.textContainer.exclusionPaths = []
    textView.textContainer.maximumNumberOfLines = 0
    textView.textContainer.lineFragmentPadding = 0
    textView.layoutManager.allowsNonContiguousLayout = false
    textView.layoutManager.hyphenationFactor = 0
    textView.layoutManager.showsInvisibleCharacters = false
    textView.layoutManager.showsControlCharacters = false
    textView.layoutManager.usesFontLeading = true

    // setup send button
    rightButton.imageEdgeInsets = .zero
    rightButton.titleEdgeInsets = .zero
    rightButton.contentEdgeInsets = .zero
    rightButton.titleLabel?.font = self.font ?? UIFont.systemFont(ofSize: 14)
    rightButton.imageView?.contentMode = .scaleAspectFit
    rightButton.imageView?.clipsToBounds = true

    self.observation = self.observe(\.textView.contentSize, options: [.new]) { [weak self] _, _ in
      if self?.suppressKVO == false {
        self?.textViewContentSizeDidChange()
      }
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    if let observer = self.observation {
      observer.invalidate()
      self.observation = nil
    }
  }

  // MARK: API

  override var isHidden: Bool {
    willSet {
      if newValue {
        self.resignResponder(animated: false)
      }
    }
  }

  var showLeftButton: Bool = true {
    didSet {
      delegate?.wantsLayout(messageView: self)
    }
  }

  var font: UIFont? {
    get { return textView.font }
    set {
      textView.font = newValue
      delegate?.wantsLayout(messageView: self)
    }
  }

  var text: String {
    get { return textView.text ?? "" }
    set {
      textView.text = newValue
      delegate?.wantsLayout(messageView: self)
    }
  }

  var textViewInset: UIEdgeInsets {
    set {
      textView.textContainerInset = newValue
      setNeedsLayout()
      delegate?.wantsLayout(messageView: self)
    }
    get { return textView.textContainerInset }
  }

  var contentInset: UIEdgeInsets {
    set {
      textView.contentInset = newValue
      setNeedsLayout()
      delegate?.wantsLayout(messageView: self)
    }
    get { return textView.contentInset }
  }

  func setPlaceholder(mode: MessageViewState, text: String) {
    self.placeholders[mode] = text
  }

  /// - Parameter accessibilityLabel: A custom `accessibilityLabel` to set on the button.
  /// If none is supplied, it will default to the icon's `accessibilityLabel`.
  func setButton(
    icon: UIImage?,
    for state: UIControl.State,
    position: ButtonPosition,
    size: CGSize? = nil,
    accessibilityLabel: String? = nil) {
    let button: UIButton
    switch position {
    case .left:
      if let size = size {
        leftButtonSize = size
      }
      button = leftButton
    case .right:
      if let size = size {
        rightButtonSize = size
      }
      button = rightButton
    }
    button.setImage(icon, for: state)
    button.accessibilityLabel = accessibilityLabel ?? icon?.accessibilityIdentifier
    buttonLayoutDidChange(button: button)
  }

  /// - Parameter accessibilityLabel: A custom `accessibilityLabel` to set on the button.
  /// If none is supplied, it will default to the the supplied `title`.
  func setButton(title: String, for state: UIControl.State, position: ButtonPosition, accessibilityLabel: String? = nil) {
    let button: UIButton
    switch position {
    case .left:
        button = leftButton
    case .right:
        button = rightButton
    }
    button.setTitle(title, for: state)
    button.accessibilityLabel = accessibilityLabel ?? title
    buttonLayoutDidChange(button: button)
  }

  var leftButtonTint: UIColor {
    get { return leftButton.tintColor }
    set {
      leftButton.tintColor = newValue
      leftButton.setTitleColor(newValue, for: .normal)
      leftButton.imageView?.tintColor = newValue
    }
  }

  var rightButtonTint: UIColor {
    get { return rightButton.tintColor }
    set {
      rightButton.tintColor = newValue
      rightButton.setTitleColor(newValue, for: .normal)
      rightButton.imageView?.tintColor = newValue
    }
  }
  
  var rightButtonIsEnable: Bool {
    get { return rightButton.isEnabled }
    set {
      rightButton.isEnabled = newValue
      rightButton.tintColor = self.shouldEnabledSend ?.cobalt400 : .sendDisable
    }
  }

  var rightButtonVerticalPosition: ButtonVerticalPosition = .top

  var shouldEnabledSend: Bool {
    return self.text.trimmingCharacters(in: .whitespacesAndNewlines) != ""
  }

  var cursorBottomFrame: CGRect {
    if let selectedRange = self.textView.selectedTextRange {
      let endRect = self.textView.caretRect(for: selectedRange.end)
      return endRect
    }
    return CGRect.zero
  }

  var maxHeight = CGFloat.greatestFiniteMagnitude {
    didSet {
      delegate?.wantsLayout(messageView: self)
    }
  }

  var maxLineCount: Int = 10 {
    didSet {
      ignoreLineHeight = maxLineHeight == 0
      self.textView.textContainer.maximumNumberOfLines = maxLineCount
      delegate?.wantsLayout(messageView: self)
    }
  }

  var maxScreenRatio: CGFloat = 1 {
    didSet {
      maxScreenRatio = 0...1 ~= maxScreenRatio ? maxScreenRatio : 0
      delegate?.wantsLayout(messageView: self)
    }
  }

  func add(accessoryView: UIView) {
    self.topAccessoryView?.removeFromSuperview()
    assert(accessoryView.bounds.height > 0, "Must have a non-zero content height")
    self.topAccessoryView = accessoryView
    addSubview(accessoryView)
    setNeedsLayout()
    delegate?.wantsLayout(messageView: self)
  }

  func add(toolbarView: UIView) {
    self.toolbarView?.removeFromSuperview()
    assert(toolbarView.bounds.height > 0, "Must have a non-zero content height")
    self.toolbarView = toolbarView
    addSubview(toolbarView)
    setNeedsLayout()
    delegate?.wantsLayout(messageView: self)
  }

  func add(bottomView: UIView) {
    self.bottomView?.removeFromSuperview()
    self.bottomView = bottomView
    addSubview(bottomView)
    setNeedsLayout()
    delegate?.wantsLayout(messageView: self)
  }

  var keyboardType: UIKeyboardType {
    get { return textView.keyboardType }
    set { textView.keyboardType = newValue }
  }

  func setVisibleTopAccessoryView(show: Bool) {
    self.topAccessoryView?.isHidden = !show
    setNeedsLayout()
    delegate?.wantsLayout(messageView: self)
  }

  func setVisibleBottomView(show: Bool) {
    self.bottomView?.isHidden = !show
    setNeedsLayout()
    delegate?.wantsLayout(messageView: self)
  }

  func addButton(target: Any, action: Selector, position: ButtonPosition) {
    let button: UIButton
    switch position {
    case .left:
      button = leftButton
    case .right:
      button = rightButton
      rightButtonAction = action
    }

    button.addTarget(target, action: action, for: .touchUpInside)
  }

  override var keyCommands: [UIKeyCommand]? {
    guard let action = rightButtonAction else { return nil }
    return [UIKeyCommand(input: "\r", modifierFlags: .command, action: action)]
  }

  func setButton(inset: CGFloat, position: ButtonPosition) {
    switch position {
    case .left:
      leftButtonInset = inset
    case .right:
      rightButtonInset = inset
    }
    setNeedsLayout()
  }

  func setButton(font: UIFont, position: ButtonPosition) {
    let button: UIButton
    switch position {
    case .left:
      button = leftButton
    case .right:
      button = rightButton
    }
    button.titleLabel?.font = font
    buttonLayoutDidChange(button: button)
  }

  var isKeyboardActive: Bool {
    return self.textView.isFirstResponder
  }

  var topInset: CGFloat = 0 {
    didSet {
      delegate?.wantsLayout(messageView: self)
    }
  }

  var leftInset: CGFloat = 0 {
    didSet {
      delegate?.wantsLayout(messageView: self)
    }
  }

  var rightInset: CGFloat = 0 {
    didSet {
      delegate?.wantsLayout(messageView: self)
    }
  }

  var bottomInset: CGFloat = 0 {
    didSet {
      delegate?.wantsLayout(messageView: self)
    }
  }

  var hideTopBorder: Bool {
    set { self.topBorderLayer.isHidden = newValue }
    get { return self.topBorderLayer.isHidden }
  }

  //factor out to implementer..
  var mode: MessageViewState {
    get { return self.state }
    set {
      switch newValue {
      case .normal:
        self.textContainerView.backgroundColor = .white
        self.toolbarView?.backgroundColor = .white
        self.topBorderLayer.backgroundColor = UIColor.grey300.cgColor
        self.textView.textColor = UIColor.grey900
        self.rightButton.tintColor = self.shouldEnabledSend ?
          .cobalt400 : .sendDisable
      case .highlight:
        self.textContainerView.backgroundColor = UIColor.orange100
        self.toolbarView?.backgroundColor = UIColor.orange100
        self.topBorderLayer.backgroundColor = UIColor.orange200.cgColor
        self.textView.textColor = UIColor.grey900
      case .disabled:
        self.textContainerView.backgroundColor = UIColor.grey200
        self.toolbarView?.backgroundColor = UIColor.grey200
        self.topBorderLayer.backgroundColor = UIColor.grey300.cgColor
        self.textView.textColor = UIColor.black20
        self.rightButton.tintColor = .sendDisable
      }
      self.textView.placeholderText = self.placeholders[newValue] ?? ""
      self.delegate?.modeDidChange(mode: newValue)
    }
  }

  // MARK: Overrides

  override func layoutSubviews() {
    super.layoutSubviews()

    topBorderLayer.frame = CGRect(
      x: bounds.minX,
      y: bounds.minY,
      width: bounds.width,
      height: 1 / UIScreen.main.scale
    )

    let safeBounds = CGRect(
      x: bounds.minX + util_safeAreaInsets.left,
      y: bounds.minY + util_safeAreaInsets.top,
      width: bounds.width - util_safeAreaInsets.left - util_safeAreaInsets.right,
      height: bounds.height - util_safeAreaInsets.top - util_safeAreaInsets.bottom
    )
    
    let leftButtonSize = self.leftButtonSize == .zero ?
      leftButton.bounds.size : self.leftButtonSize
    let rightButtonSize = self.leftButtonSize == .zero ?
      leftButton.bounds.size : self.rightButtonSize
    let leftImageHeight = leftButton.imageView?.image?.size.height ?? 0.f
    let rightImageHeight = rightButton.imageView?.image?.size.height ?? 0.f
    
    let textViewY = safeBounds.minY
    let textViewHeight = self.textViewHeight
    let textViewMaxY = textViewY + textViewHeight

    // adjust for font descender so button aligns with the text baseline
    let descender, pointSize: CGFloat
    if let font = textView.font {
      descender = floor(font.descender)
      pointSize = ceil(font.pointSize)
    } else {
      descender = 0
      pointSize = 0
    }
    let buttonYStarter = textViewMaxY - textViewInset.bottom - (pointSize - descender)/2
    // adjust by bottom offset so content is flush w/ text view
    let leftButtonFrame = CGRect(
      x: safeBounds.minX + leftButtonInset,
      y: buttonYStarter -
        (leftButtonSize.height)/2 +
        leftButton.bottomHeightOffset -
        (leftButtonSize.height - leftImageHeight)/2,
      width: leftButtonSize.width,
      height: leftButtonSize.height
    )
    leftButton.frame = showLeftButton ? leftButtonFrame : .zero

    let leftButtonMaxX = (showLeftButton ? leftButtonFrame.maxX : 0)
    let textViewFrame = CGRect(
      x: (showLeftButton ? leftButtonMaxX + leftButtonInset : 0),
      y: textViewY,
      width: safeBounds.width - leftButtonMaxX - rightButtonSize.width - rightButtonInset,
      height: textViewHeight
    )

    suppressKVO = true
    textView.frame = textViewFrame
    suppressKVO = false

    // adjust by bottom offset so content is flush w/ text view
    let rightButtonFrame = CGRect(
      x: textViewFrame.maxX - rightButtonInset,
      y: buttonYStarter -
        rightButtonSize.height/2 +
        rightButton.bottomHeightOffset -
        (rightButtonSize.height - rightImageHeight)/2,
      width: rightButtonSize.width,
      height: rightButtonSize.height
    )
    rightButton.frame = rightButtonFrame

    textContainerView.frame = CGRect(
      x: bounds.minX,
      y: bounds.minY,
      width: bounds.width,
      height: safeBounds.height
    )
    
    toolbarView?.frame = CGRect(
      x: safeBounds.minX,
      y: safeBounds.height - (toolbarView?.frame.height ?? 0),
      width: safeBounds.width,
      height: toolbarView?.frame.height ?? 0
    )
    
    var accessY: CGFloat = 0.0
    if let toolbarY = toolbarView?.frame.minY {
      accessY = toolbarY - (topAccessoryView?.frame.height ?? 0)
    } else {
      accessY = safeBounds.height - (topAccessoryView?.frame.height ?? 0)
    }
    topAccessoryView?.frame = CGRect(
      x: safeBounds.midX,
      y: accessY,
      width: safeBounds.width,
      height: topAccessoryView?.frame.height ?? 0
    )
    
  }

  @discardableResult
  func resignResponder(animated: Bool = true) -> Bool {
    UIView.setAnimationsEnabled(animated)
    let ret = textView.resignFirstResponder()
    textView.isUserInteractionEnabled = false
    UIView.setAnimationsEnabled(true)
    return ret
  }

  @discardableResult
  func becomeResponder(mode: MessageViewState? = nil, animated: Bool = true) -> Bool {
    UIView.setAnimationsEnabled(animated)
    if let mode = mode {
      self.mode = mode
    }
    let ret = textView.becomeFirstResponder()
    textView.isUserInteractionEnabled = true
    UIView.setAnimationsEnabled(true)
    return ret
  }

  func setShouldResignResponder(_ value: Bool) {
    self.textView.shouldResignResponder = value
  }

  var viewHeight: CGFloat {
    return self.height
  }

  // MARK: Private API

  internal var numberOfLines: Int {
    get { return self.textView.textContainer.maximumNumberOfLines }
    set {
      self.textView.textContainer.maximumNumberOfLines = newValue
    }
  }

  internal var height: CGFloat {
    let topHeight: CGFloat = topAccessoryView?.bounds.height ?? 0
    let contentHeight: CGFloat = toolbarView?.bounds.height ?? 0
    return textViewHeight + topHeight + contentHeight
  }

  internal var minHeight: CGFloat {
    let topHeight: CGFloat = topAccessoryView?.bounds.height ?? 0
    let contentHeight: CGFloat = toolbarView?.bounds.height ?? 0
    return textViewHeight + topHeight + contentHeight + bottomInset
  }

  internal var maxLineHeight: CGFloat {
    return (font?.lineHeight ?? 0) * CGFloat(maxLineCount)
  }

  internal var maxScreenRatioHeight: CGFloat {
    return maxScreenRatio * ((superview?.frame.height ?? 0) - heightOffset)
  }

  internal var calculatedMaxHeight: CGFloat {
    return ignoreLineHeight == true ?
      min(maxScreenRatioHeight, maxHeight) :
      min(maxScreenRatioHeight, maxLineHeight, maxHeight)
  }

  internal var textViewHeight: CGFloat {
    let maxValue = max(textView.contentSize.height, 54)
    return ceil(min(calculatedMaxHeight, maxValue))//min height))
  }

  internal func buttonLayoutDidChange(button: UIButton) {
    button.sizeToFit()
    setNeedsLayout()
  }

  internal func textViewContentSizeDidChange() {
    delegate?.sizeDidChange(messageView: self)
    textView.alwaysBounceVertical = textView.contentSize.height > calculatedMaxHeight
  }

  // MARK: MessageTextViewListener

  func didChange(textView: CHMessageTextView) {
    delegate?.textDidChange(text: textView.text)
  }

  func didChangeSelection(textView: CHMessageTextView) {
    delegate?.selectionDidChange(messageView: self)
  }

  func didStartEditing(textView: CHMessageTextView) {
    self.textViewBecomeActive?(self)
    delegate?.textViewDidStartEditing(messageView: self)
  }

  func willChangeRange(textView: CHMessageTextView, to range: NSRange) {}
}
