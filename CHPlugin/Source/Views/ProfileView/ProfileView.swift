//
//  ProfileView.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 13..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class ProfileView: BaseView {

  // MARK: - Constants

  struct Metric {
    static let paddingTop = 14.f
    static let rowHeight = 48.f
    static let dividerTopBottomPadding = 10.f
    static let dividerHeight = 1.f
    static let footerTopPadding = 10.f
    static let footerHeight = 36.f
  }

  struct Font {
    static let deleteButton = UIFont.boldSystemFont(ofSize: 16)
  }

  struct Color {
    static let divider = CHColors.lightGray
    static let deleteButton = CHColors.dark
  }

  // MARK: - Properties

  var clickSubject = PublishSubject<Any?>()

  var rows = [ProfileViewRow]()

  let separator = UIView().then {
    $0.backgroundColor = Color.divider
  }

  let deleteRow = UIView()

  let deleteButton = UIButton().then {
    $0.titleLabel?.font = Font.deleteButton
    $0.setTitle(CHAssets.localized("ch.chat.delete_menu_title"), for: .normal)
    $0.setTitleColor(Color.deleteButton, for: .normal)
  }

  let footerView = ProfileFooterView()

  var viewModel: ProfileViewModelType?

  // MARK: - Initializing

  override func initialize() {
    super.initialize()
    self.backgroundColor = CHColors.white
    self.addSubview(self.separator)
    self.addSubview(self.deleteRow)
    self.deleteRow.addSubview(self.deleteButton)
    self.addSubview(self.footerView)

    _ = self.deleteButton.signalForClick()
      .subscribe({ _ in
        self.clickSubject.onNext(nil)
    })
  }

  // MARK: - Configuring

  func didDeleteButtonClick() -> PublishSubject<Any?> {
    return self.clickSubject
  }
  
  func configure(_ viewModel: ProfileViewModelType) {
    self.rows.forEach({ $0.removeFromSuperview() })
    self.rows.removeAll()
    
    viewModel.cells.forEach { (cell) in
      let row = ProfileViewRow()
      row.configure(cell)
      self.rows.append(row)
    }
    
    self.rows.forEach({ self.addSubview($0) })

    self.viewModel = viewModel

    self.setNeedsLayout()
    self.layoutIfNeeded()
  }

  // MARK: - Layout 

  override func layoutSubviews() {
    super.layoutSubviews()

    var previousView: UIView? = nil
    self.rows.forEach { (view) in
      view.snp.remakeConstraints({ (make) in
        make.trailing.equalToSuperview()
        make.leading.equalToSuperview()
        make.size.equalTo(CGSize(width: self.width, height: Metric.rowHeight))
        if previousView == nil {
          make.top.equalToSuperview().inset(Metric.paddingTop)
        } else {
          make.top.equalTo((previousView?.snp.bottom)!)
        }
      })
      previousView = view
    }

    self.separator.snp.remakeConstraints { (make) in
      make.trailing.equalToSuperview()
      make.leading.equalToSuperview()
      make.size.equalTo(CGSize(width: self.width, height: Metric.dividerHeight))
      make.top.equalTo((previousView?.snp.bottom)!).offset(Metric.dividerTopBottomPadding)
    }

    self.deleteRow.snp.remakeConstraints { (make) in
      make.trailing.equalToSuperview()
      make.leading.equalToSuperview()
      make.size.equalTo(CGSize(width: self.width, height: Metric.rowHeight))
      make.top.equalTo(self.separator.snp.bottom).offset(Metric.dividerTopBottomPadding)
    }

    self.deleteButton.snp.remakeConstraints { (make) in
      make.leading.equalToSuperview().offset(17)
      make.centerY.equalToSuperview()
    }

    self.footerView.snp.remakeConstraints { (make) in
      make.top.equalTo(self.deleteRow.snp.bottom).offset(Metric.footerTopPadding)
      make.leading.equalToSuperview()
      make.size.equalTo(CGSize(width: self.width, height: Metric.footerHeight))
    }
  }

  func measureHeight() -> CGFloat {
    guard self.viewModel != nil else { return 0.f }
    var height = Metric.paddingTop
    height += Metric.rowHeight * CGFloat(self.viewModel!.cells.count)
    height += Metric.dividerTopBottomPadding * 2
    height += Metric.dividerHeight
    height += Metric.rowHeight
    height += Metric.footerTopPadding
    height += Metric.footerHeight
    return height
  }
}
