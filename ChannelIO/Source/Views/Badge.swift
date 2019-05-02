//
//  Badge.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 7..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import SnapKit

final class Badge: NeverClearView {

  // MARK: Constants
  var minWidth: CGFloat = 10.f {
    didSet {
      self.widthConstraint?.update(offset: self.minWidth)
    }
  }
  
  struct Metric {
    static let padding = 5.f // TODO: Expose to outside
  }

  struct Font {
    static let text = UIFont.boldSystemFont(ofSize: 13)
  }

  struct Color {
    static let text = CHColors.white
    static let background = CHColors.neonRed
    static let border = CHColors.warmPink
  }

  // MARK: Properties

  let label = UILabel().then {
    $0.font = Font.text
    $0.textColor = Color.text
    $0.textAlignment = .center
  }
  
  private var widthConstraint: Constraint?

  // MARK: Initializing

  override func initialize() {
    super.initialize()
    self.clipsToBounds = true
    
    self.backgroundColor = Color.background
    self.layer.borderColor = Color.border.cgColor
    self.layer.borderWidth = 1.f
    
    self.addSubview(self.label)
    
    self.label.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      self.widthConstraint = make.width.greaterThanOrEqualTo(self.minWidth).constraint
      make.leading.greaterThanOrEqualToSuperview().inset(5)
      make.trailing.greaterThanOrEqualToSuperview().inset(5)
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }

  // MARK: Configuring

  func configure(_ badgeCount: Int) {
    if badgeCount > 99 {
      self.label.text = "99+"
    } else {
      self.label.text = "\(badgeCount)"
    }
    
    self.setNeedsLayout()
    self.layoutIfNeeded()
  }

  // MARK: Layout

  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = self.frame.size.height / 2
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelSize = self.label.sizeThatFits(size)
    return CGSize(width: max(labelSize.width + Metric.padding * 2, self.minWidth), height: size.height)
  }
}
