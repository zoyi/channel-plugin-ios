//
//  FluidButton.swift
//  ChannelIO
//
//  Created by Haeun Chung on 28/05/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift

class RoundLabelBackButton: UIControl {
  
  private var backImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = CHAssets.getImage(named: "back")?.withRenderingMode(.alwaysTemplate)
    imageView.contentMode = .center
    return imageView
  }()
  
  private var labelContainer = UIView()
  
  private var label: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 12)
    label.textAlignment = .center
    return label
  }()
  
  private var disposeBag = DisposeBag()
  
  private var normalColor: UIColor?
  private var highlightColor: UIColor?
  
  private var imageCenterXConstraint: Constraint?
  private var labelLeadingConstraint: Constraint?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    sharedInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    sharedInit()
  }
  
  private func sharedInit() {
    self.addSubview(self.backImageView)
    self.addSubview(self.labelContainer)
    self.labelContainer.addSubview(label)
    
    self.backImageView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.equalToSuperview()
      make.centerY.equalToSuperview()
      self.imageCenterXConstraint = make.centerX.equalToSuperview().inset(-4).constraint
    }
    
    self.labelContainer.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      self.labelLeadingConstraint = make.leading.equalTo(self.backImageView.snp.trailing).offset(4).constraint
      make.trailing.equalToSuperview()
      make.height.equalTo(20)
      make.width.greaterThanOrEqualTo(20)
      make.centerY.equalToSuperview()
    }
    
    self.label.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(5)
      make.trailing.equalToSuperview().inset(5)
      make.top.equalToSuperview().inset(2)
      make.bottom.equalToSuperview().inset(2)
    }
    
    self.rx.controlEvent([.touchDown])
      .asObservable()
      .subscribe(onNext: { [weak self] (_) in
        self?.layer.removeAllAnimations()
        self?.backImageView.tintColor = self?.highlightColor
        self?.labelContainer.backgroundColor = self?.highlightColor
      }).disposed(by: self.disposeBag)
    
    self.rx.controlEvent([.touchUpInside, .touchDragExit, .touchCancel])
      .asObservable()
      .subscribe(onNext: { [weak self] (_) in
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
          self?.backImageView.tintColor = self?.normalColor
          self?.labelContainer.backgroundColor = self?.normalColor
        }) { (completed) in
          
        }
      }).disposed(by: self.disposeBag)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.labelContainer.layer.cornerRadius = 10
  }
  
  func configure(text: String?, textColor: UIColor?, tintColor: UIColor?) {
    self.label.textColor = textColor
    self.backImageView.tintColor = tintColor
    self.labelContainer.backgroundColor = tintColor
    
    self.normalColor = tintColor
    self.highlightColor = textColor == .black ?
      UIColor.black10.withAlphaComponent(0.7) :
      tintColor?.withAlphaComponent(0.7)
    
    if let text = text, text != "" {
      self.label.text = text
      self.labelContainer.isHidden = false
      self.labelLeadingConstraint?.activate()
      self.imageCenterXConstraint?.deactivate()
    } else {
      self.labelContainer.isHidden = true
      self.labelLeadingConstraint?.deactivate()
      self.imageCenterXConstraint?.activate()
    }
  }
}
