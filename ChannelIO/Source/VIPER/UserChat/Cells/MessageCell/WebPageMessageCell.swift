//
//  WebPageMessageCell.swift
//  CHPlugin
//
//  Created by Haeun Chung on 26/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit
import Reusable
import SnapKit

class WebPageMessageCell: MessageCell {
  private struct Metrics {
    static let webViewWithTranslateTop = 20.f
    static let webViewWithoutTranslateTop = 3.f
    static let resendButtonRight = 4.f
    static let resendButtonSide = 40.f
  }
  
  let webView = WebPageMessageView()
  
  private var topConstraint: Constraint?
  private var trailingConstraint: Constraint?
  private var leadingConstraint: Constraint?
  var webBottomConstraint: Constraint?
  
  override func initialize() {
    super.initialize()
    self.contentView.addSubview(self.webView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.messageBottomConstraint?.deactivate()
    
    self.webView.snp.makeConstraints { make in
      self.topConstraint = make.top.equalTo(self.translateView.snp.bottom)
        .offset(Metrics.webViewWithoutTranslateTop).constraint
      self.trailingConstraint = make.right.equalToSuperview()
        .inset(Metric.cellRightPadding).constraint
      self.leadingConstraint = make.left.equalToSuperview()
        .inset(Metric.messageLeftMinMargin).constraint
      self.webBottomConstraint = make.bottom.equalToSuperview().constraint
    }
    
    self.resendButtonView.snp.remakeConstraints { make in
      make.width.equalTo(Metrics.resendButtonSide)
      make.height.equalTo(Metrics.resendButtonSide)
      make.bottom.equalTo(self.webView.snp.bottom)
      make.right.equalTo(self.webView.snp.left).inset(Metrics.resendButtonRight)
    }
  }
  
  override func configure(
    _ viewModel: MessageCellModelType,
    dataSource: (UITableViewDataSource & UITableViewDelegate),
    presenter: UserChatPresenterProtocol? = nil,
    row: Int = 0) {
    super.configure(viewModel, dataSource: dataSource, presenter: presenter, row: row)
    
    guard let webpage = viewModel.webpage else {
      self.webView.isHidden = true
      return
    }
    
    self.webView.isHidden = false
    self.webView.configure(message: viewModel.message)
    
    if viewModel.createdByMe == true {
      self.trailingConstraint?.update(inset: Metric.cellRightPadding)
      self.leadingConstraint?.update(inset: Metric.messageLeftMinMargin)
    } else {
      self.trailingConstraint?.update(inset: Metric.messageRightMinMargin)
      self.leadingConstraint?.update(inset: Metric.bubbleLeftMargin)
    }
    
    self.topConstraint?.update(offset: viewModel.showTranslation ?
      Metrics.webViewWithTranslateTop :
      Metrics.webViewWithoutTranslateTop
    )
  }
  
  override class func cellHeight(fits width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
    var height = super.cellHeight(fits: width, viewModel: viewModel)
    
    height += viewModel.showTranslation ?
      Metrics.webViewWithTranslateTop : Metrics.webViewWithoutTranslateTop
    
    let bubbleMaxWidth = viewModel.createdByMe ?
      width - Metric.messageLeftMinMargin - Metric.cellRightPadding :
      width - Metric.messageRightMinMargin - Metric.bubbleLeftMargin
    
    if let webpage = viewModel.webpage {
      height += WebPageMessageView.viewHeight(fits: bubbleMaxWidth, webpage: webpage)
    }
    return height
  }
}
