//
//  TextBlockTableViewCell.swift
//  ChannelIO
//
//  Created by intoxicated on 20/01/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import SnapKit

let placeHolder = UITextView().then {
  $0.textContainer.lineFragmentPadding = 0
  $0.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
}

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

  func configure(with model: MessageCellModel, blockModel: CHMessageBlock) {
    self.textView.configure(model, blockModel: blockModel)
    
    if model.createdByMe {
      self.leadingFixedConstraint?.deactivate()
      self.leadingFlexConstraint?.activate()
      self.trailingFixedConstraint?.activate()
      self.trailingFlexConstraint?.deactivate()
    } else {
      self.leadingFixedConstraint?.activate()
      self.leadingFlexConstraint?.deactivate()
      self.trailingFixedConstraint?.activate()
      self.trailingFlexConstraint?.deactivate()
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
      blockModel: blockModel,
      edgeInset: edgeInset
    )
  }
}

