//
//  ImageMessageCell.swift
//  CHPlugin
//
//  Created by Haeun Chung on 26/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

protocol MediaMessageProtocol {
  var mediaCollectionView: MediaCollectionView { get set }
}

class MediaMessageCell: MessageCell, MediaMessageProtocol {
  private struct Metric {
    static let mediaInSideMargin = 40.f
    static let mediaOutSideMargin = 75.f
    static let mediaTop = 6.f
    static let mediaTopToName = 8.f
    static let mediaTopToText = 8.f
    static let mediaTopToTextTranslate = 20.f
  }

  var mediaCollectionView = MediaCollectionView()
  var gesture: UILongPressGestureRecognizer?

  private var mediaTopConstraint: Constraint?
  private var mediaTopToNameTopConstraint: Constraint?
  private var mediaTopToTextViewTopContraint: Constraint?
  
  var leftTextViewConstraint: Constraint?
  var leftConstraint: Constraint?
  var rightConstraint: Constraint?

  override func initialize() {
    super.initialize()
    self.contentView.addSubview(self.mediaCollectionView)
  }

  override func setLayouts() {
    super.setLayouts()
    self.messageBottomConstraint?.deactivate()

    self.mediaCollectionView.snp.makeConstraints { make in
      self.mediaTopConstraint = make.top.equalToSuperview()
        .inset(Metric.mediaTop).priority(750).constraint
      self.mediaTopToNameTopConstraint = make.top.equalTo(self.usernameLabel.snp.bottom)
        .offset(Metric.mediaTopToName).priority(850).constraint
      self.mediaTopToTextViewTopContraint = make.top.equalTo(self.textBlocksView.snp.bottom)
        .offset(Metric.mediaTopToText).constraint
      
      self.leftTextViewConstraint = make.leading.equalTo(self.textBlocksView.snp.leading)
        .priority(750).constraint
      self.leftConstraint = make.leading.equalToSuperview()
        .inset(Metric.mediaInSideMargin).priority(850).constraint
      self.rightConstraint = make.trailing.equalToSuperview()
        .inset(Metric.mediaOutSideMargin).constraint
      
      make.bottom.equalToSuperview()
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
  }

  override class func cellHeight(
    fits width: CGFloat,
    viewModel: MessageCellModelType) -> CGFloat {
    var height = super.cellHeight(fits: width, viewModel: viewModel)
    height += MediaCollectionView.viewHeight(fit: width, models: viewModel.files) + 8
    return height
  }

  override func configure(
    _ viewModel: MessageCellModelType,
    dataSource: (UITableViewDataSource & UITableViewDelegate),
    presenter: UserChatPresenterProtocol? = nil,
    row: Int = 0) {
    super.configure(viewModel, dataSource: dataSource, presenter: presenter, row: row)
    self.mediaCollectionView.configure(models: viewModel.files)

    if viewModel.canTranslate {
      self.mediaTopToTextViewTopContraint?.update(offset: Metric.mediaTopToTextTranslate)
      self.mediaTopToTextViewTopContraint?.activate()
      self.mediaTopConstraint?.deactivate()
      self.mediaTopToNameTopConstraint?.deactivate()
    } else if viewModel.blocks.count != 0 {
      self.mediaTopToTextViewTopContraint?.update(offset: Metric.mediaTopToText)
      self.mediaTopToTextViewTopContraint?.activate()
      self.mediaTopConstraint?.deactivate()
      self.mediaTopToNameTopConstraint?.deactivate()
    } else if viewModel.isContinuous {
      self.mediaTopToTextViewTopContraint?.deactivate()
      self.mediaTopConstraint?.activate()
      self.mediaTopToNameTopConstraint?.deactivate()
    } else {
      self.mediaTopToTextViewTopContraint?.deactivate()
      self.mediaTopConstraint?.deactivate()
      self.mediaTopToNameTopConstraint?.activate()
    }
    
    if self.viewModel?.createdByMe == true {
      self.leftTextViewConstraint?.deactivate()
      self.leftConstraint?.activate()
      self.rightConstraint?.update(inset: Metric.cellRightPadding)
      self.mediaCollectionView.changeFlowLayout(horizontalAlignment: .right)
    } else {
      self.leftTextViewConstraint?.activate()
      self.leftConstraint?.deactivate()
      self.rightConstraint?.update(inset: 75)
      self.mediaCollectionView.changeFlowLayout(horizontalAlignment: .left)
    }
  }

  func setDataSource(
    _ source: UICollectionViewDataSource & UICollectionViewDelegateFlowLayout,
    at row: Int) {
    self.mediaCollectionView.setDataSource(source, at: row)
  }
}
