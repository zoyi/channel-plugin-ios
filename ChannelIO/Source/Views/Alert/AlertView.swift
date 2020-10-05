//
//  AlertView.swift
//  ChannelIO
//
//  Created by Jam on 2020/03/05.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import UIKit

class AlertView: BaseView {
  let contentView = UIView().then {
    $0.clipsToBounds = true
  }
  let titleView = UIView()
  let titleLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 18)
    $0.numberOfLines = 0
    $0.textColor = UIColor.grey900
    $0.textAlignment = .center
  }
  let descriptionLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.numberOfLines = 0
    $0.textColor = UIColor.grey900
    $0.textAlignment = .center
  }

  var mainView: AlertMainContentProtoocl?
  let divider = UIView().then {
    $0.backgroundColor = UIColor.grey200
  }

  var actionsView = UIView()
  var actionViewList = [AlertActionButton]()
  var alertType: AlertType = .normal

  var dividerTopConstraint: Constraint?
  let dividerHeight = 1.0 / UIScreen.main.scale

  override func initialize() {
    super.initialize()

    self.backgroundColor = UIColor.clear

    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOffset = CGSize(width: 0.f, height: 4.f)
    self.layer.shadowRadius = 4.f
    self.layer.shadowOpacity = 0.3

    self.contentView.backgroundColor = UIColor.white
    self.contentView.layer.cornerRadius = 6
    self.contentView.clipsToBounds = true

    self.titleView.addSubview(self.titleLabel)
    self.contentView.addSubview(self.titleView)
    self.contentView.addSubview(self.descriptionLabel)
    self.contentView.addSubview(self.divider)
    self.contentView.addSubview(self.actionsView)

    self.addSubview(self.contentView)
  }

  override func setLayouts() {
    super.setLayouts()

    self.contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.titleView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.top.equalToSuperview()
    }

    self.titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.bottom.equalToSuperview().inset(8)
      make.centerX.equalToSuperview()
      make.leading.equalToSuperview().inset(15)
      make.trailing.equalToSuperview().inset(15)
    }

    self.descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(self.titleView.snp.bottom)
      make.centerX.equalToSuperview()
      make.leading.equalToSuperview().inset(20)
      make.trailing.equalToSuperview().inset(20)
    }

    if let mainView = self.mainView as? UIView {
      mainView.snp.remakeConstraints({ make in
        if let descText = self.descriptionLabel.text, descText != "" {
          make.top.equalTo(self.descriptionLabel.snp.bottom).offset(10)
        } else if let titleText = self.titleLabel.text, titleText != "" {
          make.top.equalTo(self.titleView.snp.bottom)
        } else {
          make.top.equalToSuperview().inset(14).priority(750)
        }
        make.leading.equalToSuperview()
        make.trailing.equalToSuperview()
      })
    }

    self.divider.snp.remakeConstraints { make in
      if let mainView = self.mainView as? UIView {
        self.dividerTopConstraint = make.top.equalTo(mainView.snp.bottom).constraint
      } else {
        self.dividerTopConstraint = make.top.equalTo(self.titleView.snp.bottom).constraint
      }
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.height.equalTo(dividerHeight)
    }

    self.actionsView.snp.remakeConstraints { make in
      make.top.equalTo(self.divider.snp.bottom)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }

  func addTitle(text: String?, textColor: UIColor? = nil) {
    if let text = text {
      self.titleLabel.text = text
      self.titleView.isHidden = false
    } else {
      self.titleView.isHidden = true
    }

    if let textColor = textColor {
      self.titleLabel.textColor = textColor
    }

    self.setLayouts()
  }

  func addAttributedTitle(text: NSAttributedString?) {
    if let text = text {
      self.titleLabel.attributedText = text
      self.titleView.isHidden = false
    } else {
      self.titleView.isHidden = true
    }

    self.setLayouts()
  }

  func addDescription(text: String?, textColor: UIColor? = nil) {
    if let text = text {
      self.descriptionLabel.attributedText = text.addLineHeight(
        height: 20,
        font: UIFont.systemFont(ofSize: 14),
        color: UIColor.grey900,
        alignment: .center)
      self.descriptionLabel.isHidden = false
    } else {
      self.descriptionLabel.isHidden = true
    }

    if let textColor = textColor {
      self.descriptionLabel.textColor = textColor
    }
  }

  func addDescription(attributedText: NSAttributedString?) {
    if let attrText = attributedText {
      self.descriptionLabel.attributedText = attrText
    } else {
      self.descriptionLabel.isHidden = true
    }
  }

  func addMainSection(type: AlertType, text: String?, attrText: NSAttributedString? = nil) {
    if let mainView = self.mainView as? UIView {
      mainView.removeFromSuperview()
    }

    if text == nil && attrText == nil {
      self.dividerTopConstraint?.update(offset: 10)
      return
    }

    self.dividerTopConstraint?.update(offset: 0)
    self.alertType = type

    var view: AlertMainContentProtoocl?

    switch type {
    case .normal:
      view = AlertItemView()
    case .check(let shouldCheck):
      view = AlertCheckItemView(initialValue: shouldCheck)
    default:
      view = AlertItemView()
    }

    if let attrText = attrText {
      view?.configureItem(attrText: attrText)
    } else if let text = text {
      view?.configureItem(text: text)
    }

    if let view = view as? UIView {
      self.addSubview(view)
    }
    self.mainView = view

    self.setLayouts()
  }

  func addAction(actionTitle: String, type: AlertActionType = .normal, handler: ((Bool) -> Void)?) {
    let action = AlertActionButton(title: actionTitle, type: type)
    _ = action.signalForClick().subscribe { _ in
      handler?(self.mainView?.isChecked ?? false)
    }

    self.actionsView.addSubview(action)
    self.actionViewList.append(action)
    self.layoutIfNeeded()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    switch self.alertType {
    case .actionSheet:
      self.verticalLayout()
    default:
      if self.actionViewList.count <= 2 {
        self.horizontalLayout()
      } else {
        self.verticalLayout()
      }
    }
  }

  private func horizontalLayout() {
    var lastView: UIView?
    for (index, action) in self.actionViewList.enumerated() {
      action.snp.remakeConstraints({ [weak self] make in
        guard let s = self else { return }
        if let lastView = lastView {
          make.leading.equalTo(lastView.snp.trailing)
        } else {
          make.leading.equalToSuperview()
        }

        make.width.equalTo(s.bounds.width / CGFloat(s.actionViewList.count)).priority(750)
        make.height.equalTo(48)
        make.top.equalToSuperview()
        make.bottom.equalToSuperview()
        if index == s.actionViewList.count - 1 {
          make.trailing.equalToSuperview()
        }

        lastView = action
      })
    }
  }

  func verticalLayout() {
    var lastView: UIView?
    for (index, action) in self.actionViewList.enumerated() {
      action.snp.remakeConstraints({ make in
        if let lastView = lastView {
          make.top.equalTo(lastView.snp.bottom)
        } else {
          make.top.equalToSuperview()
        }
        make.leading.equalToSuperview()
        make.trailing.equalToSuperview()
        make.height.equalTo(48)

        if index == self.actionViewList.count - 1 {
          make.bottom.equalToSuperview()
        }

        lastView = action
      })
    }
  }
}

