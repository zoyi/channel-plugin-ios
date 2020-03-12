//
//  MessageCell.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 9..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift
import SnapKit

class MessageCell: BaseTableViewCell {
  weak var presenter: UserChatPresenterProtocol?
  struct Font {
    static let usernameLabel = UIFont.boldSystemFont(ofSize: 12)
    static let timestampLabel = UIFont.systemFont(ofSize: 11)
  }
  
  struct Color {
    static let username = CHColors.dark
    static let timestamp = CHColors.blueyGrey
  }

  struct Metric {
    static let cellRightPadding = 10.f
    static let cellLeftPadding = 10.f
    static let messageLeftMinMargin = 107.f
    static let messageRightMinMargin = 74.f
    static let messageTop = 4.f
    static let avatarWidth = 26.f
    static let avatarRightPadding = 6.f
    static let bubbleLeftMargin = 40.f
    static let usernameHeight = 16.f
    static let timestampHeight = 16.f
    static let usernameLeading = 8.f
    static let timestampLeading = 6.f
    static let cellTopPaddingOfContinous = 3.f
    static let cellTopPaddingDefault = 16.f
    static let translateViewTop = 4.f
    static let translateViewLeading = 12.f
    static let translateHeight = 12.f + TranslateView.bottomInset
    static let resendButtonSide = 24.f
    static let resendButtonRight = -4.f
    static let textViewInset = UIEdgeInsets(top: -2, left: 0, bottom: 0, right: 0)
  }
  
  let avatarView = AvatarView().then {
    $0.showBorder = false
    $0.showOnline = false
    $0.layer.cornerRadius = 13.f
  }
  
  let usernameLabel = UILabel().then {
    $0.font = Font.usernameLabel
    $0.textColor = Color.username
  }
  
  let timestampLabel = UILabel().then {
    $0.font = Font.timestampLabel
    $0.textColor = Color.timestamp
  }
  
  let textView = TextMessageView()
  let translateView = TranslateView()
  let resendButton = UIButton().then {
    $0.isHidden = true
    $0.setImage(CHAssets.getImage(named: "resend"), for: .normal)
  }

  var viewModel: MessageCellModelType?
  var titleHeightConstraint: Constraint?
  var messageBottomConstraint: Constraint?
  var translateHeightConstraint: Constraint?
  var translateTopConstraint: Constraint?
  // MARK: Initializing

  override func initialize() {
    super.initialize()

    self.contentView.addSubview(self.avatarView)
    self.contentView.addSubview(self.usernameLabel)
    self.contentView.addSubview(self.timestampLabel)
    self.contentView.addSubview(self.textView)
    self.contentView.addSubview(self.translateView)
    self.contentView.addSubview(self.resendButton)
    
    self.resendButton.signalForClick()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        self?.presenter?.didClickOnRetry(
          for: self?.viewModel?.message,
          from: self?.resendButton
        )
        self?.resendButton.isHidden = true
      }).disposed(by :self.disposeBag)
    
    self.translateView.signalForClick()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        self?.presenter?.didClickOnTranslate(for: self?.viewModel?.message)
      }).disposed(by: self.disposeBag)
  }

  // MARK: Configuring
  func configure(
    _ viewModel: MessageCellModelType,
    dataSource: (UITableViewDataSource & UITableViewDelegate),
    presenter: UserChatPresenterProtocol? = nil,
    row: Int = 0) {
    self.presenter = presenter 
    self.viewModel = viewModel
    
    self.usernameLabel.text = viewModel.name
    self.usernameLabel.isHidden = viewModel.usernameIsHidden
    
    self.timestampLabel.text = viewModel.timestamp
    self.timestampLabel.isHidden = viewModel.timestampIsHidden
    
    self.avatarView.configure(viewModel.avatarEntity)
    self.avatarView.isHidden = viewModel.avatarIsHidden
    
    self.textView.configure(viewModel)
    self.textView.messageView.textContainerInset = viewModel.isDeleted ?
      .zero : Metric.textViewInset
    self.resendButton.isHidden = !viewModel.isFailed
    
    self.translateView.configure(with: viewModel)
    self.translateHeightConstraint?
      .update(offset: viewModel.showTranslation ? Metric.translateHeight : 0)
    self.translateTopConstraint?
      .update(offset: viewModel.showTranslation ? Metric.translateViewTop : 0)
    self.layoutViews()
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.avatarView.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(Metric.cellLeftPadding)
      make.top.equalToSuperview().inset(Metric.cellTopPaddingDefault)
      make.size.equalTo(CGSize(width: Metric.avatarWidth, height: Metric.avatarWidth))
    }
    
    self.usernameLabel.snp.makeConstraints { make in
      make.left.equalTo(self.avatarView.snp.right).offset(Metric.usernameLeading)
      make.top.equalTo(self.avatarView.snp.top)
      make.height.equalTo(Metric.usernameHeight)
    }
    
    self.timestampLabel.snp.makeConstraints { make in
      make.left.equalTo(self.usernameLabel.snp.right).offset(Metric.timestampLeading)
      make.height.equalTo(Metric.timestampHeight)
      make.centerY.equalTo(self.usernameLabel)
    }
    
    self.textView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(Metric.bubbleLeftMargin)
      make.trailing.lessThanOrEqualToSuperview().inset(Metric.messageLeftMinMargin)
      make.trailing.equalToSuperview().inset(Metric.messageLeftMinMargin).priority(750)
      make.top.equalTo(self.usernameLabel.snp.bottom).offset(Metric.messageTop)
    }
    
    self.translateView.snp.makeConstraints { make in
      self.translateTopConstraint = make.top.equalTo(self.textView.snp.bottom)
        .offset(Metric.translateViewTop).constraint
      make.leading.equalTo(self.textView.snp.leading)
        .offset(Metric.translateViewLeading)
      self.translateHeightConstraint = make.height.equalTo(0).constraint
      self.messageBottomConstraint = make.bottom.equalToSuperview().constraint
    }
    
    self.resendButton.snp.remakeConstraints { (make) in
      make.size.equalTo(CGSize(width: Metric.resendButtonSide, height: Metric.resendButtonSide))
      make.bottom.equalTo(self.textView.snp.bottom)
      make.right.equalTo(self.textView.snp.left).inset(Metric.resendButtonRight)
    }
  }
  
  class func cellHeight(fits width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
    var viewHeight : CGFloat = 0.0
    
    if viewModel.isContinuous {
      viewHeight += Metric.cellTopPaddingOfContinous
    } else {
      viewHeight += Metric.cellTopPaddingDefault + Metric.messageTop
      viewHeight += viewModel.createdByMe ?
        Metric.timestampHeight :  Metric.usernameHeight
    }

    let bubbleMaxWidth = viewModel.createdByMe ?
      width - Metric.messageLeftMinMargin - Metric.cellRightPadding :
      width - Metric.messageRightMinMargin - Metric.bubbleLeftMargin

    viewHeight += TextMessageView.viewHeight(fit: bubbleMaxWidth, model: viewModel)
    if viewModel.showTranslation {
      viewHeight += Metric.translateViewTop + Metric.translateHeight
    }
    
    return viewHeight
  }
}

// MARK: layout
extension MessageCell {
  func layoutViews() {
    if self.viewModel?.createdByMe == true {
      if self.viewModel?.isContinuous == true {
        self.layoutCoutinuousByMe()
      } else {
        self.layoutDefaultByMe()
      }
    } else {
      if self.viewModel?.isContinuous == true {
        self.layoutContinuousByOther()
      } else {
        self.layoutDefaultByOther()
      }
    }
  }
  
  func layoutCoutinuousByMe() {
    self.textView.snp.remakeConstraints { make in
      make.left.greaterThanOrEqualToSuperview().inset(Metric.messageLeftMinMargin)
      make.right.equalToSuperview().inset(Metric.cellRightPadding)
      make.top.equalToSuperview().inset(Metric.cellTopPaddingOfContinous)
    }
  }
  
  func layoutDefaultByMe() {
    self.timestampLabel.snp.remakeConstraints { make in
      make.trailing.equalToSuperview().inset(Metric.cellRightPadding)
      make.height.equalTo(Metric.timestampHeight)
      make.top.equalToSuperview().inset(Metric.cellTopPaddingDefault)
    }
    
    self.usernameLabel.snp.remakeConstraints { make in
      make.left.equalTo(self.avatarView.snp.right).offset(0)
      make.top.equalTo(self.avatarView.snp.top)
    }
    
    self.textView.snp.remakeConstraints { make in
      make.left.greaterThanOrEqualToSuperview().inset(Metric.messageLeftMinMargin)
      make.right.equalToSuperview().inset(Metric.cellRightPadding)
      make.top.equalTo(self.timestampLabel.snp.bottom).offset(Metric.messageTop)
    }
  }
  
  func layoutContinuousByOther() {
    self.avatarView.snp.remakeConstraints { make in
      make.leading.equalToSuperview().offset(Metric.cellLeftPadding)
      make.top.equalToSuperview().inset(Metric.cellTopPaddingOfContinous)
      make.size.equalTo(CGSize(width: Metric.avatarWidth, height: Metric.avatarWidth))
    }
    
    self.usernameLabel.snp.remakeConstraints { make in
      make.left.equalTo(self.avatarView.snp.right).offset(Metric.usernameLeading)
      make.top.equalTo(self.avatarView.snp.top)
      make.height.equalTo(Metric.usernameHeight)
    }
    
    self.timestampLabel.snp.remakeConstraints { make in
      make.left.equalTo(self.usernameLabel.snp.right).offset(Metric.timestampLeading)
      make.height.equalTo(Metric.timestampHeight)
      make.centerY.equalTo(self.usernameLabel)
    }
    
    self.textView.snp.remakeConstraints { make in
      make.left.equalToSuperview().inset(Metric.bubbleLeftMargin)
      make.right.lessThanOrEqualToSuperview().inset(Metric.messageRightMinMargin)
      make.top.equalToSuperview().inset(Metric.cellTopPaddingOfContinous)
    }
  }
  
  func layoutDefaultByOther() {
    self.avatarView.snp.remakeConstraints { make in
      make.leading.equalToSuperview().offset(Metric.cellLeftPadding)
      make.top.equalToSuperview().inset(Metric.cellTopPaddingDefault)
      make.size.equalTo(CGSize(width: Metric.avatarWidth, height: Metric.avatarWidth))
    }
    
    self.usernameLabel.snp.remakeConstraints { make in
      make.left.equalTo(self.avatarView.snp.right).offset(Metric.usernameLeading)
      make.top.equalTo(self.avatarView.snp.top)
      make.height.equalTo(Metric.usernameHeight)
    }
    
    self.timestampLabel.snp.remakeConstraints { make in
      make.left.equalTo(self.usernameLabel.snp.right).offset(Metric.timestampLeading)
      make.height.equalTo(Metric.timestampHeight)
      make.centerY.equalTo(self.usernameLabel)
    }
    
    self.textView.snp.remakeConstraints { make in
      make.left.equalToSuperview().inset(Metric.bubbleLeftMargin)
      make.right.lessThanOrEqualToSuperview().inset(Metric.messageRightMinMargin)
      make.top.equalTo(self.usernameLabel.snp.bottom)
        .offset(Metric.messageTop)
    }
  }
}
