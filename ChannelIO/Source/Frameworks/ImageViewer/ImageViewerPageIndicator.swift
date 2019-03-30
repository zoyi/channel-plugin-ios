//
//  ImageViewerPageIndicator.swift
//  Alamofire
//
//  Created by Haeun Chung on 29/03/2019.
//

import Foundation
import UIKit
import SnapKit

class CHPageIndicator: BaseView, PageIndicatorView {
  public var view: UIView {
    return self
  }
  
  public var numberOfPages: Int = 0 {
    didSet {
      updateLabel()
    }
  }
  
  public var page: Int = 0 {
    didSet {
      updateLabel()
    }
  }
  
  let containerView = UIView().then {
    $0.layer.cornerRadius = 18
    $0.clipsToBounds = true
  }
  
  let backgroundView = UIView().then {
    $0.backgroundColor = UIColor.black
    $0.alpha = 0.7
  }
  
  let label = UILabel().then {
    $0.textColor = UIColor.white
    $0.font = UIFont.boldSystemFont(ofSize: 14)
    $0.textAlignment = .center
  }
  
  override func initialize() {
    super.initialize()
    self.containerView.addSubview(self.backgroundView)
    self.containerView.addSubview(self.label)
    self.addSubview(self.containerView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.containerView.snp.makeConstraints { (make) in
      make.centerY.equalToSuperview()
      make.centerX.equalToSuperview()
      make.height.equalTo(36)
    }
    
    self.backgroundView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.label.snp.makeConstraints { (make) in
      make.centerY.equalToSuperview()
      make.centerX.equalToSuperview()
      make.leading.equalToSuperview().inset(15)
      make.trailing.equalToSuperview().inset(15)
    }
  }
  
  private func updateLabel() {
    self.label.text = "\(page+1) / \(numberOfPages)"
  }
  
  public override func sizeToFit() {
    let width = self.label.text?.width(with: UIFont.boldSystemFont(ofSize: 14)) ?? 0
    self.frame.size = CGSize(width: width + 30, height: 36)
  }
}
