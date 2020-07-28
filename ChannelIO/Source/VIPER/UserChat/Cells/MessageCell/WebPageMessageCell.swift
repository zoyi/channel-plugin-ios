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
  private struct WebMetrics {
    static let webViewTranslateTop = 3.f
    static let resendButtonRight = -4.f
    static let resendButtonSide = 40.f
    static let webViewBottom = 8.f
  }
  
  let webView = WebPageMessageView()
  
  private var webViewTopConstraint: Constraint?
  private var webViewTopToNameTopConstraint: Constraint?
  private var webViewTopToTranslateConstraint: Constraint?
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
      self.webViewTopConstraint = make.top.equalToSuperview()
        .inset(WebMetrics.webViewTranslateTop).priority(750).constraint
      self.webViewTopToNameTopConstraint = make.top.equalTo(self.usernameLabel.snp.bottom)
        .offset(WebMetrics.webViewTranslateTop).priority(850).constraint
      self.webViewTopToTranslateConstraint = make.top.equalTo(self.translateView.snp.bottom)
        .offset(WebMetrics.webViewTranslateTop).constraint
      self.trailingConstraint = make.right.equalToSuperview()
        .inset(Metric.cellRightPadding).constraint
      self.leadingConstraint = make.left.equalToSuperview()
        .inset(Metric.messageLeftMinMargin).constraint
      self.webBottomConstraint = make.bottom.equalToSuperview()
        .inset(WebMetrics.webViewBottom).constraint
    }
    
    self.resendButton.snp.remakeConstraints { make in
      make.width.equalTo(WebMetrics.resendButtonSide)
      make.height.equalTo(WebMetrics.resendButtonSide)
      make.bottom.equalTo(self.webView.snp.bottom)
      make.right.equalTo(self.webView.snp.left).inset(WebMetrics.resendButtonRight)
    }
  }
  
  override func configure(
    _ viewModel: MessageCellModelType,
    dataSource: (UITableViewDataSource & UITableViewDelegate),
    presenter: UserChatPresenterProtocol? = nil,
    row: Int = 0) {
    super.configure(viewModel, dataSource: dataSource, presenter: presenter, row: row)
    
    guard viewModel.webpage != nil else {
      self.webView.isHidden = true
      return
    }
    
    self.webView.isHidden = false
    self.webView.configure(message: viewModel.message)
    
    if viewModel.showTranslation {
      self.webViewTopToTranslateConstraint?.activate()
      self.webViewTopConstraint?.deactivate()
      self.webViewTopToNameTopConstraint?.deactivate()
    } else if viewModel.text != nil || !viewModel.buttons.isEmpty {
      self.webViewTopToTranslateConstraint?.activate()
      self.webViewTopConstraint?.deactivate()
      self.webViewTopToNameTopConstraint?.deactivate()
    } else if viewModel.isContinuous {
      self.webViewTopToTranslateConstraint?.deactivate()
      self.webViewTopConstraint?.activate()
      self.webViewTopToNameTopConstraint?.deactivate()
    } else {
      self.webViewTopToTranslateConstraint?.deactivate()
      self.webViewTopConstraint?.deactivate()
      self.webViewTopToNameTopConstraint?.activate()
    }
    
    if viewModel.createdByMe == true {
      self.trailingConstraint?.update(inset: Metric.cellRightPadding)
      self.leadingConstraint?.update(inset: Metric.messageLeftMinMargin)
    } else {
      self.trailingConstraint?.update(inset: Metric.messageRightMinMargin)
      self.leadingConstraint?.update(inset: Metric.bubbleLeftMargin)
    }
  }
  
  override class func cellHeight(
    fits width: CGFloat,
    viewModel: MessageCellModelType) -> CGFloat {
    var height = super.cellHeight(fits: width, viewModel: viewModel)
    
    height += WebMetrics.webViewTranslateTop
    
    let bubbleMaxWidth = viewModel.createdByMe ?
      width - Metric.messageLeftMinMargin - Metric.cellRightPadding :
      width - Metric.messageRightMinMargin - Metric.bubbleLeftMargin
    
    if let webpage = viewModel.webpage {
      height += WebPageMessageView.viewHeight(fits: bubbleMaxWidth, webpage: webpage)
    }
    return height + WebMetrics.webViewBottom
  }
}
