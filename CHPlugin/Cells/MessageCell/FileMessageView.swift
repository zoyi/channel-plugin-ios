//
//  FileView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 16/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import SnapKit

class FileMessageView : BaseView {
  
  //MARK: Constant
  
  struct Metric {
    static let HEIGHT = 70.f
  }
  
  struct Constant {
    static let cornerRadius = 6.f
    static let borderWidth: CGFloat = 1
  }
  
  struct Font {
    static let titleLabel = UIFont.boldSystemFont(ofSize: 15)
    static let sizeLabel = UIFont.boldSystemFont(ofSize: 13)
    static let extensionLabel = UIFont.boldSystemFont(ofSize: 13)
  }
  
  struct Color {
    static let borderColor = CHColors.darkTwo
    static let titleLabel = CHColors.dark
    static let sizeLabel = CHColors.gray
    static let extensionLabel = CHColors.gray
  }
  
  //MARK: Properties 
  
  let imageView = UIImageView()
  let titleLabel = UILabel().then {
    $0.font = Font.titleLabel
    $0.textColor = CHColors.dark //
  }
  
  let infoLabel = UILabel().then {
    $0.font = Font.sizeLabel
    $0.textColor = CHColors.blueyGrey
  }
  
  let arrowImageView = UIImageView().then {
    $0.contentMode = UIViewContentMode.center
    $0.image = CHAssets.getImage(named: "chevronRightSmall")
  }
  
  //MARK: init
  
  override func initialize() {
    super.initialize()
    
    self.layer.cornerRadius = Constant.cornerRadius
    self.layer.borderColor = Color.borderColor.cgColor
    self.layer.borderWidth = Constant.borderWidth
    
    self.addSubview(self.imageView)
    self.addSubview(self.titleLabel)
    self.addSubview(self.infoLabel)
    self.addSubview(self.arrowImageView)
  }
  
  func configure(message: MessageCellModelType) {
    guard let file = message.file else { return }
    self.titleLabel.text = file.name
    self.infoLabel.text = "\(file.size) • \(file.category)"

    switch file.category {
    case "zip", "archive":
      self.imageView.image = CHAssets.getImage(named: "zip")
      break
    case "pdf", "image", "psd", "text", "audio", "sketch",
         "font", "vector", "pages", "numbers", "xls", "data",
         "ppt", "system", "script", "key", "hwp":
      self.imageView.image = CHAssets.getImage(named: file.category)
      break
    default:
      self.imageView.image = CHAssets.getImage(named: "else")
      break
    }
  }
  
  //MARK: layout
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.imageView.snp.makeConstraints { (make) in
      make.size.equalTo(CGSize(width:33, height:42))
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(14)
    }
    
    self.arrowImageView.snp.makeConstraints { (make) in
      make.size.equalTo(CGSize(width:20, height:20))
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(6)
    }
    
    self.titleLabel.snp.makeConstraints { [weak self] (make) in
      make.left.equalTo((self?.imageView.snp.right)!).offset(12)
      make.right.equalTo((self?.arrowImageView.snp.left)!).offset(6)
      make.top.equalToSuperview().inset(14)
    }
    
    self.infoLabel.snp.makeConstraints { [weak self] (make) in
      make.left.equalTo((self?.titleLabel.snp.left)!)
      make.top.equalTo((self?.titleLabel.snp.bottom)!).offset(1)
      make.bottom.equalTo((self?.imageView.snp.bottom)!)
    }
  }
  
  class func viewHeight(fits width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
    return 70
  }
}
