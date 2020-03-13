//
//  AlertItemView.swift
//  ChannelIO
//
//  Created by Jam on 2020/03/05.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import RxSwift
import UIKit

protocol AlertMainContentProtoocl {
  var message: String { get set }
  var type: AlertType { get set }
  var isChecked: Bool { get set }

  func configureItem(text: String?)
  func configureItem(attrText: NSAttributedString?)
}

enum AlertActionType {
  case normal
  case cancel
  case destructive
}

class AlertItemView: BaseView, AlertMainContentProtoocl {
  var message: String = ""
  var isChecked: Bool = false
  var type: AlertType = .normal

  let textLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.textColor = UIColor.grey900
  }

  override func initialize() {
    super.initialize()
    self.backgroundColor = .clear
    self.addSubview(self.textLabel)
  }

  override func setLayouts() {
    super.setLayouts()

    self.textLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.equalToSuperview().inset(20)
      make.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(20)
    }
  }

  func configureItem(text: String?) {
    guard let text = text else {
      self.isHidden = true
      return
    }

    self.textLabel.attributedText = text.addLineHeight(
      height: 20,
      font: UIFont.systemFont(ofSize: 14),
      color: UIColor.grey900,
      alignment: .center)
  }

  func configureItem(attrText: NSAttributedString?) {
    guard let attrText = attrText else {
      self.isHidden = true
      return
    }

    self.textLabel.attributedText = attrText
  }
}

class AlertCheckItemView: BaseView, AlertMainContentProtoocl {
  var message: String = ""
  var isChecked: Bool = false
  var type: AlertType = .check(value: false)

  let checkImageView = UIImageView().then {
    $0.image = UIImage(named: "unchecked")
    $0.highlightedImage = UIImage(named: "checked")
    $0.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
  }

  let textLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.textColor = UIColor.grey900
  }

  init(initialValue: Bool) {
    super.init(frame: CGRect.zero)
    self.type = .check(value: initialValue)
    self.checkImageView.isHighlighted = initialValue
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func initialize() {
    super.initialize()

    _ = self.signalForClick().subscribe { _ in
      self.checkImageView.isHighlighted.toggle()
      self.isChecked = self.checkImageView.isHighlighted

      let color = self.checkImageView.isHighlighted ?
        UIColor.grey900 : UIColor.grey500

      self.textLabel.textColor = color
      self.backgroundColor = UIColor.white
    }

    self.addSubview(self.checkImageView)
    self.addSubview(self.textLabel)
  }

  override func setLayouts() {
    super.setLayouts()

    self.checkImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(18)
      make.top.equalToSuperview().inset(8)
    }

    self.textLabel.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(20)
      make.leading.equalTo(self.checkImageView.snp.trailing).offset(8)
      make.top.equalToSuperview().inset(4)
      make.bottom.equalToSuperview().inset(20)
    }
  }

  func configureItem(text: String?) {
    guard let text = text else { return }

    self.message = text

    let color = self.checkImageView.isHighlighted ?
      UIColor.grey900 : UIColor.grey500

    self.textLabel.attributedText = text.addLineHeight(
      height: 20,
      font: UIFont.systemFont(ofSize: 14),
      color: color)
  }

  func configureItem(attrText: NSAttributedString?) {
    guard let attrText = attrText else { return }

    self.message = attrText.string
    self.textLabel.attributedText = attrText
  }

  func isSelected() -> Bool {
    return self.checkImageView.isHighlighted
  }
}

class AlertActionButton: UIButton {
  var didSetBackground = false

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  convenience init(title: String, type: AlertActionType = .normal) {
    self.init(type: .custom)

    self.setTitle(title, for: .normal)
    self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    self.backgroundColor = UIColor.white

    switch type {
    case .normal:
      self.setTitleColor(.grey900, for: .normal)
    case .cancel:
      self.setTitleColor(.grey500, for: .normal)
    case .destructive:
      self.setTitleColor(.red400, for: .normal)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    if self.frame.size.width > 0 && self.frame.size.height > 0 && !self.didSetBackground {
      self.didSetBackground = true
      self.setBackgroundColor(color: UIColor.dark20, forUIControlState: .selected)
      self.setBackgroundColor(color: UIColor.dark20, forUIControlState: .highlighted)
    }
  }
}

