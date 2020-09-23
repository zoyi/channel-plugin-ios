//
//  ImageMessageCell.swift
//  CHPlugin
//
//  Created by Haeun Chung on 26/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit
//import RxSwift

protocol MediaMessageProtocol {
  var mediaCollectionView: MediaCollectionView { get set }
}

class MediaMessageCell: MessageCell, MediaMessageProtocol {
  private struct MediaMetrics {
    static let mediaInSideMargin = 40.f
    static let mediaOutSideMargin = 75.f
    static let mediaTop = 6.f
  }

  var mediaCollectionView = MediaCollectionView()
  var gesture: UILongPressGestureRecognizer?

  private var mediaTopConstraint: Constraint?
  private var mediaTopToNameTopConstraint: Constraint?
  private var mediaTopToTextViewTopContraint: Constraint?
  
  var leftTextViewConstraint: Constraint?
  var leftConstraint: Constraint?
  var rightConstraint: Constraint?
  var mediaViewBottomConstraint: Constraint?

  override func initialize() {
    super.initialize()
    self.contentView.addSubview(self.mediaCollectionView)
  }

  override func setLayouts() {
    super.setLayouts()
    self.messageBottomConstraint?.deactivate()

    self.mediaCollectionView.snp.makeConstraints { make in
      self.mediaTopConstraint = make.top.equalToSuperview()
        .inset(MediaMetrics.mediaTop).priority(750).constraint
      self.mediaTopToNameTopConstraint = make.top.equalTo(self.usernameLabel.snp.bottom)
        .offset(MediaMetrics.mediaTop).priority(850).constraint
      self.mediaTopToTextViewTopContraint = make.top.equalTo(self.translateView.snp.bottom)
        .offset(MediaMetrics.mediaTop).constraint
      self.leftTextViewConstraint = make.leading.equalTo(self.textView.snp.leading)
        .priority(750).constraint
      self.leftConstraint = make.leading.equalToSuperview()
        .inset(MediaMetrics.mediaInSideMargin).priority(850).constraint
      self.rightConstraint = make.trailing.equalToSuperview()
        .inset(MediaMetrics.mediaOutSideMargin).constraint
      
      self.mediaViewBottomConstraint = make.bottom.equalToSuperview().constraint
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
  }

  override class func cellHeight(
    fits width: CGFloat,
    viewModel: MessageCellModelType) -> CGFloat {
    var height = super.cellHeight(fits: width, viewModel: viewModel)
    let bubbleMaxWidth = viewModel.createdByMe ?
      width - Metric.messageLeftMinMargin - Metric.cellRightPadding :
      width - Metric.messageRightMinMargin - Metric.bubbleLeftMargin
    height += MediaMetrics.mediaTop
    height += MediaCollectionView.viewHeight(fit: bubbleMaxWidth, models: viewModel.files)
    return height
  }

  override func configure(
    _ viewModel: MessageCellModelType,
    dataSource: (UITableViewDataSource & UITableViewDelegate),
    presenter: UserChatPresenterProtocol? = nil,
    row: Int = 0) {
    super.configure(viewModel, dataSource: dataSource, presenter: presenter, row: row)
    self.mediaCollectionView.configure(models: viewModel.files)

    if viewModel.showTranslation {
      self.mediaTopToTextViewTopContraint?.update(offset: MediaMetrics.mediaTop)
      self.mediaTopToTextViewTopContraint?.activate()
      self.mediaTopConstraint?.deactivate()
      self.mediaTopToNameTopConstraint?.deactivate()
    } else if viewModel.text != nil || !viewModel.buttons.isEmpty {
      self.mediaTopToTextViewTopContraint?.update(offset: MediaMetrics.mediaTop)
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
      self.rightConstraint?.update(inset: Metric.messageRightMinMargin)
      self.mediaCollectionView.changeFlowLayout(horizontalAlignment: .left)
    }
  }

  func setDataSource(
    _ source: UICollectionViewDataSource & UICollectionViewDelegateFlowLayout,
    at row: Int) {
    self.mediaCollectionView.setDataSource(source, at: row)
  }
}
