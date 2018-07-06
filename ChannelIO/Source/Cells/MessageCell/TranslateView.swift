//
//  TranslateView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 06/07/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation

class TranslateView: BaseView {
  let translateLoader = UIActivityIndicatorView().then {
    $0.activityIndicatorViewStyle = .gray
    //$0.isHidden = true
    $0.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
  }
  let translateLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 10)
    $0.textColor = CHColors.blueyGrey
    $0.textAlignment = .center
    $0.text = CHAssets.localized("show_translate")
  }
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.translateLoader)
    self.addSubview(self.translateLabel)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.translateLoader.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
    }
    
    self.translateLabel.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
  }
  
  func configure(with viewModel: MessageCellModelType) {
    self.isHidden = viewModel.canTranslate != true
    self.translateLabel.isHidden = viewModel.translateState == .loading
    
    if viewModel.translateState == .loading {
      self.translateLoader.startAnimating()
    } else if viewModel.translateState == .translated {
      self.translateLabel.text = CHAssets.localized("undo_translate")
      self.translateLoader.stopAnimating()
    } else if viewModel.translateState == .original {
      self.translateLabel.text = CHAssets.localized("show_translate")
      self.translateLoader.stopAnimating()
    }
  }
}
