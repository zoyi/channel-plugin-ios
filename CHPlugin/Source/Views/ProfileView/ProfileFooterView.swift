//
//  ProfileFooterView.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 13..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import RxSwift
import ManualLayout

class ProfileFooterView: BaseView {

  // MARK: - Constants
  struct Constant {
    static let termURL = "https://channel.io/terms"
    static let homeURL = "https://channel.io"
  }
  
  struct Fonts {
    static let channelLabel = UIFont.systemFont(ofSize: 11)
    static let termsLabel = UIFont.boldSystemFont(ofSize: 11)
  }
  
  struct Colors {
    static let channelLabel = CHColors.gray
    static let termsLabel = CHColors.gray
  }
  
  struct Metric {
    static let paddingLeft = 16.f
    static let paddingRight = 16.f
  }
  
  // MARK: - Properties
  
  let channelLabel = UILabel().then {
    $0.font = Fonts.channelLabel
    $0.textColor = Colors.channelLabel
    let attributedString = NSMutableAttributedString(
      string: "Powered by",
      attributes: [NSAttributedStringKey.font: Fonts.channelLabel]
    )
    attributedString.append(NSMutableAttributedString(
      string: " Channel",
      attributes: [NSAttributedStringKey.font: Fonts.termsLabel])
    )
    $0.attributedText = attributedString
  }
  
  let termsLabel = UILabel().then {
    $0.font = Fonts.termsLabel
    $0.textColor = Colors.termsLabel
    $0.textAlignment = .right
    $0.text = CHAssets.localized("ch.agreement.button")
  }
  
  let disposeBeg = DisposeBag()

  // MARK: - Initializing
  
  override func initialize() {
    super.initialize()
    self.termsLabel.signalForClick()
      .subscribe(onNext: { [weak self] (event) in
      self?.showChannelTerms()
    }).disposed(by: self.disposeBeg)
    
    self.channelLabel.signalForClick()
      .subscribe(onNext: { [weak self] (event) in
      self?.showChannelHomepage()
    }).disposed(by: self.disposeBeg)
    
    self.addSubview(self.channelLabel)
    self.addSubview(self.termsLabel)
  }

  // MARK: - Layout
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.channelLabel.top = 0
    self.channelLabel.left = Metric.paddingLeft
    self.channelLabel.sizeToFit()
    self.channelLabel.height = self.height
    
    self.termsLabel.top = 0
    self.termsLabel.sizeToFit()
    self.termsLabel.left = self.width - Metric.paddingRight - self.termsLabel.width
    self.termsLabel.height = self.height
  }

  // MARK: - Helper methods

  func showChannelTerms() {
    guard let url = URL(string: Constant.termURL) else { return }
    url.open()
  }

  func showChannelHomepage() {
    guard let url = URL(string: Constant.homeURL) else { return }
    url.open()
  }
}
