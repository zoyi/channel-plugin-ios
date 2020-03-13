//
//  MessageTextView.swift
//  MessageViewController
//
//  Created by Ryan Nystrom on 12/31/17.
//

import UIKit

public protocol MessageTextViewListener: class {
  func didChange(textView: CHMessageTextView)
  func didChangeSelection(textView: CHMessageTextView)
  func willChangeRange(textView: CHMessageTextView, to range: NSRange)
  func didStartEditing(textView: CHMessageTextView)
}

open class CHMessageTextView: UITextView, UITextViewDelegate, UITextPasteDelegate {
  internal let placeholderLabel = UILabel()
  internal var listeners: NSHashTable<AnyObject> = NSHashTable.weakObjects()

  open var shouldResignResponder: Bool = true

  open var defaultFont = UIFont.systemFont(ofSize: 15) {
    didSet {
      defaultTextAttributes[.font] = defaultFont
    }
  }

  open var defaultTextColor = UIColor.black {
    didSet {
      defaultTextAttributes[NSAttributedString.Key.foregroundColor] = defaultTextColor
    }
  }

  internal var defaultTextAttributes: [NSAttributedString.Key: Any] = {
    let style = NSMutableParagraphStyle()
    style.paragraphSpacingBefore = 2
    style.lineHeightMultiple = 1
    return [NSAttributedString.Key.paragraphStyle: style]
    }() {
    didSet {
      typingAttributes = defaultTextAttributes
    }
  }

  override open var font: UIFont? {
    didSet {
      defaultFont = font ?? .preferredFont(forTextStyle: .body)
      placeholderLabel.font = font
      placeholderLayoutDidChange()
    }
  }

  override open var textColor: UIColor? {
    didSet {
      defaultTextColor = textColor ?? .black
    }
  }

  override open var textAlignment: NSTextAlignment {
    didSet {
      placeholderLabel.textAlignment = textAlignment
      placeholderLayoutDidChange()
    }
  }

  override open var attributedText: NSAttributedString! {
    get { return super.attributedText }
    set {
      let didChange = super.attributedText != newValue
      super.attributedText = newValue
      if didChange {
          textViewDidChange(self)
      }
    }
  }

  override public init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    self.delegate = self

    if #available(iOS 11.0, *) {
      self.pasteDelegate = self
    }
    commonInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.delegate = self
    commonInit()
  }

  // MARK: Public API

  public func add(listener: MessageTextViewListener) {
    assert(Thread.isMainThread)
    listeners.add(listener)
  }

  public var placeholderText: String {
    get { return placeholderLabel.text ?? "" }
    set {
      placeholderLabel.text = newValue
      placeholderLayoutDidChange()
    }
  }

  public var placeholderTextColor: UIColor {
    get { return placeholderLabel.textColor }
    set { placeholderLabel.textColor = newValue }
  }

  // MARK: Overrides

  override open func layoutSubviews() {
    super.layoutSubviews()

    let placeholderSize = self.placeholderLabel.bounds.size
    placeholderLabel.frame = CGRect(
        x: textContainerInset.left,
        y: textContainerInset.top,
        width: min(placeholderSize.width, self.bounds.size.width - textContainerInset.right - textContainerInset.left),
        height: placeholderSize.height
    )
  }

  // MARK: Private API

  private func commonInit() {
    bounces = false
    placeholderLabel.backgroundColor = .clear
    placeholderLabel.font = font
    placeholderLabel.textColor = UIColor.grey500
    placeholderLabel.textAlignment = textAlignment
    addSubview(placeholderLabel)
    updatePlaceholderVisibility()

    defaultTextAttributes[NSAttributedString.Key.font] = defaultFont
    defaultTextAttributes[NSAttributedString.Key.foregroundColor] = defaultTextColor
  }

  internal func enumerateListeners(block: (MessageTextViewListener) -> Void) {
    for listener in listeners.objectEnumerator() {
      guard let listener = listener as? MessageTextViewListener else { continue }
      block(listener)
    }
  }

  private func placeholderLayoutDidChange() {
    placeholderLabel.sizeToFit()
    setNeedsLayout()
  }

  private func updatePlaceholderVisibility() {
    placeholderLabel.isHidden = !text.isEmpty
  }

  // MARK: UITextViewDelegate

  public func textViewDidChange(_ textView: UITextView) {
    typingAttributes = defaultTextAttributes
    updatePlaceholderVisibility()
    enumerateListeners { $0.didChange(textView: self) }
  }

  public func textViewDidChangeSelection(_ textView: UITextView) {
    enumerateListeners { $0.didChangeSelection(textView: self) }
  }

  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    enumerateListeners { $0.willChangeRange(textView: self, to: range) }
    return true
  }

  public func textViewDidBeginEditing(_ textView: UITextView) {
    enumerateListeners { $0.didStartEditing(textView: self) }
  }

  public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    return self.shouldResignResponder
  }

  public func textViewDidEndEditing(_ textView: UITextView) { }

  //Weird paste bug in UIKit
  @available(iOS 11.0, *)
  public func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting, shouldAnimatePasteOf attributedString: NSAttributedString, to textRange: UITextRange) -> Bool {
    return false
  }
}
