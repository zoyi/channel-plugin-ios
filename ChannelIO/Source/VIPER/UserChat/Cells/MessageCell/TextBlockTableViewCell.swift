//
//  TextBlockTableViewCell.swift
//  ChannelIO
//
//  Created by intoxicated on 20/01/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import SnapKit



class TextBlockTableViewCell: BaseTableViewCell {
  var textView = TextMessageView()

  var leadingFlexConstraint: Constraint?
  var leadingFixedConstraint: Constraint?
  var trailingFlexConstraint: Constraint?
  var trailingFixedConstraint: Constraint?
  
  override func initialize() {
    super.initialize()
    self.backgroundColor = .clear
    self.contentView.addSubview(self.textView)
  }

  override func setLayouts() {
    super.setLayouts()
    
    self.textView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      self.leadingFlexConstraint = make.leading.greaterThanOrEqualToSuperview().constraint
      self.leadingFixedConstraint = make.leading.equalToSuperview().constraint
      make.bottom.equalToSuperview()
      self.trailingFlexConstraint = make.trailing.lessThanOrEqualToSuperview().constraint
      self.trailingFixedConstraint = make.trailing.equalToSuperview().constraint
    }
  }

  static func cellHeight(
    fit width: CGFloat,
    model: MessageCellModelType,
    blockModel: CHMessageBlock?,
    edgeInset: UIEdgeInsets? = nil) -> CGFloat {
    return TextMessageView.viewHeight(
      fit: width,
      model: model,
      edgeInset: edgeInset
    )
  }
}

