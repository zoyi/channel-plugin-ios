//
//  ProfileInputView.swift
//  ChannelIO
//
//  Created by R3alFr3e on 4/11/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift

class ProfileItemBaseView: BaseView {
  struct Metric {
    static let titleTop = 2.f
    static let titleLeading = 14.f
    static let indexLeading = 10.f
    static let indexTrailing = 14.f
    static let fieldTop = 24.f
    static let fieldLeading = 12.f
    static let fieldTrailing = 12.f
    static let fieldHeight = 43.f
    static let viewHeight = 73.f
  }
  
  let titleLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = .grey500
  }
  let indexLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.isHidden = true
    $0.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
    $0.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
  }
  
  var fieldView: Actionable? {
    get {
      return nil
    }
  }
  var model: MessageCellModelType?
  var index: Int = 0
  var item: CHProfileItem?
  var fieldType: ProfileInputType = .text
  
  let disposeBag = DisposeBag()
  weak var presenter: UserChatPresenterProtocol? = nil
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.titleLabel)
    self.addSubview(self.indexLabel)
    self.addSubview((self.fieldView?.view)!)
    
    self.fieldView?
      .signalForFocus()
      .bind { [weak self] focus in
        self?.presenter?.profileIsFocus(focus: focus)
      }.disposed(by: self.disposeBag)
    
    self.fieldView?
      .signalForText()?
      .bind { [weak self] (text) in
        self?.setTitle(with: self?.item?.name)
      }.disposed(by: self.disposeBag)
    
    self.fieldView?
      .signalForAction()
      .bind { [weak self] value in
        if let index = self?.index, let item = self?.model?.profileItems[index] {
          self?.fieldView?.setLoading()
          self?.presenter?.didClickOnProfileUpdate(
            with: self?.model?.message,
            key: item.key,
            type: item.type,
            value: value
          ).subscribe(onNext: { (completed) in
            if !completed {
              self?.fieldView?.setInvalid()
              self?.setInvalidTitle(with: CHAssets.localized("ch.profile_form.error"))
            }
          }).disposed(by: self!.disposeBag)
        }
      }.disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.titleLabel.snp.makeConstraints { (make) in
      make.top.equalToSuperview().inset(Metric.titleTop)
      make.left.equalToSuperview().inset(Metric.titleLeading)
    }
    
    self.indexLabel.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.titleLabel.snp.top)!)
      make.left.equalTo((self?.titleLabel.snp.right)!).offset(Metric.indexLeading)
      make.right.equalToSuperview().inset(Metric.indexTrailing)
    }

    self.fieldView?.view.snp.makeConstraints({ (make) in
      make.left.equalToSuperview().inset(Metric.fieldLeading)
      make.right.equalToSuperview().inset(Metric.fieldTrailing)
      make.top.equalToSuperview().inset(Metric.fieldTop)
      make.height.equalTo(Metric.fieldHeight)
    })
  }
  
  func configure(model: MessageCellModelType, index: Int?, presenter: UserChatPresenterProtocol?) {
    guard let index = index else { return }
    self.presenter = presenter
    self.item = model.profileItems[index]
    self.model = model
    self.index = index

    self.titleLabel.text = self.item?.name
    
    let current = "\(index + 1)"
    let currentText = current.addFont(
      UIFont.systemFont(ofSize: 13),
      color: .grey900,
      on: NSRange(location: 0, length: current.count))
    let total = "/\(model.profileItems.count)"
    let totalText = total.addFont(
      UIFont.systemFont(ofSize: 13),
      color: .grey300,
      on: NSRange(location: 0, length: total.count))
    self.indexLabel.isHidden = false
    self.indexLabel.attributedText = currentText.combine(totalText)
  }
  
  func setInvalidTitle(with text: String?) {
    self.titleLabel.text = text
    self.titleLabel.textColor = .orange400
  }
  
  func setTitle(with text: String?) {
    self.titleLabel.text = text
    self.titleLabel.textColor = .grey500
  }
  
  class func viewHeight() -> CGFloat {
    return Metric.viewHeight
  }
}
