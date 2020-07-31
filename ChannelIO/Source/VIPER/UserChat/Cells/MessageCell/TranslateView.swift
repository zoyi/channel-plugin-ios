//
//  TranslateView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 06/07/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import SnapKit

class TranslateView: BaseView {
  let translateLoader = UIActivityIndicatorView().then {
    $0.style = .gray
    $0.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
  }
  let arrowImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "chevronTranslate")
    $0.isHidden = true
  }
  let translateLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 10)
    $0.textColor = .grey500
    $0.textAlignment = .center
    $0.text = CHAssets.localized("ch.show_translate")
  }
  static let bottomInset = 5.f
  
  var labelLeadingConstraint: Constraint?
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.translateLoader)
    self.addSubview(self.arrowImageView)
    self.addSubview(self.translateLabel)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.translateLoader.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
    }
    
    self.arrowImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.translateLabel.snp.centerY)
      make.height.equalTo(10.f)
      make.width.equalTo(5.f)
      make.leading.equalToSuperview().inset(0)
    }
    
    self.translateLabel.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.bottom.equalToSuperview().inset(TranslateView.bottomInset)
      make.trailing.equalToSuperview()
      self.labelLeadingConstraint = make.leading.equalToSuperview().inset(0).constraint
    }
  }
  
  func configure(with viewModel: MessageCellModelType) {
    self.translateLabel.isHidden = viewModel.translateState == .loading
    
    if viewModel.translateState == .loading {
      self.translateLoader.startAnimating()
    } else if viewModel.translateState == .translated {
      self.arrowImageView.isHidden = false
      self.labelLeadingConstraint?.update(inset: 8)
      self.translateLabel.text = CHAssets.localized("ch.undo_translate")
      self.translateLoader.stopAnimating()
    } else {
      self.arrowImageView.isHidden = true
      self.labelLeadingConstraint?.update(inset: 0)
      self.translateLabel.text = CHAssets.localized("ch.show_translate")
      self.translateLoader.stopAnimating()
    }
  }
}
