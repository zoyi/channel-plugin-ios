//
//  UserChatCell.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 14..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import Reusable
import SnapKit

final class UserChatCell: BaseTableViewCell, Reusable {
  struct Constants {
    static let titleLabelNumberOfLines = 1
    static let messageLabelNumberOfLines = 2
    static let welcomeNumberOfLines = 8
    static let timestampLabelNumberOfLines = 1
  }

  struct Metrics {
    static let cellTopPadding = 13.f
    static let cellLeadingPadding = 16.f
    static let cellTrailingPadding = 16.f
    static let titleHeight = 18.f
    static let titleBottomPadding = 3.f
    static let timestampBottomPadding = 16.f
    static let avatarTrailingPadding = 10.f
    static let avatarWidth = 36.f
    static let avatarHeight = 36.f
    static let badgeHeight = 22.f
    static let badgeLeadingPadding = 20.f
    static let cellHeight = 80.f
    static let messageLabelTrailingPadding = 52.f
    static let messageLabelBottomPadding = 5.f
  }

  struct Font {
    static let titleLabel = UIFont.boldSystemFont(ofSize: 14)
    static let messageLabel = UIFont.systemFont(ofSize: 14)
    static let timestampLabel = UIFont.systemFont(ofSize: 11)
  }

  struct Color {
    static let selectionColor = CHColors.snow
    static let titleLabel = CHColors.charcoalGrey
    static let messageLabel = CHColors.charcoalGrey
    static let timestampLabel = CHColors.blueyGrey
  }
  
  let bgView = UIView().then {
    $0.backgroundColor = Color.selectionColor
  }

  let titleLabel = UILabel().then {
    $0.font = Font.titleLabel
    $0.textColor = Color.titleLabel
    $0.numberOfLines = Constants.titleLabelNumberOfLines
  }

  let timestampLabel = UILabel().then {
    $0.font = Font.timestampLabel
    $0.textColor = Color.timestampLabel
    $0.textAlignment = .right
    $0.numberOfLines = Constants.timestampLabelNumberOfLines
    $0.setContentCompressionResistancePriority(
      UILayoutPriority(rawValue: 1000), for: .horizontal
    )
  }

  let avatarView = AvatarView()

  let badge = Badge().then {
    $0.minWidth = 12.f
  }

  let messageLabel = UILabel().then {
    $0.font = Font.messageLabel
    $0.textColor = Color.messageLabel
    $0.numberOfLines = Constants.messageLabelNumberOfLines
  }
  
  // MARK: Initializing

  override func initialize() {
    self.selectedBackgroundView = self.bgView
    self.contentView.addSubview(self.titleLabel)
    self.contentView.addSubview(self.timestampLabel)
    self.contentView.addSubview(self.avatarView)
    self.contentView.addSubview(self.badge)
    self.contentView.addSubview(self.messageLabel)

    self.avatarView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(Metrics.cellTopPadding)
      make.leading.equalToSuperview().inset(Metrics.cellLeadingPadding)
      make.size.equalTo(CGSize(width: Metrics.avatarWidth, height: Metrics.avatarHeight))
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(Metrics.cellTopPadding)
      make.height.equalTo(Metrics.titleHeight)
      make.leading.equalTo(self.avatarView.snp.trailing).offset(Metrics.avatarTrailingPadding)
    }
    
    self.timestampLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(Metrics.cellTopPadding)
      make.trailing.equalToSuperview().inset(Metrics.cellTrailingPadding)
      make.leading.equalTo(self.titleLabel.snp.trailing).offset(Metrics.cellTrailingPadding)
    }
    
    self.messageLabel.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(Metrics.titleBottomPadding)
      make.leading.equalTo(self.avatarView.snp.trailing).offset(Metrics.avatarTrailingPadding)
      make.trailing.equalToSuperview().inset(Metrics.messageLabelTrailingPadding)
      make.bottom.lessThanOrEqualToSuperview().inset(Metrics.messageLabelBottomPadding)
    }
    
    self.badge.snp.makeConstraints { make in
      make.top.equalTo(self.timestampLabel.snp.bottom).offset(Metrics.timestampBottomPadding)
      make.trailing.equalToSuperview().inset(Metrics.cellTrailingPadding)
      make.height.equalTo(Metrics.badgeHeight)
    }
  }
  
  func configure(_ viewModel: UserChatCellModelType) {
    self.titleLabel.text = viewModel.title
    self.timestampLabel.text = viewModel.timestamp
    self.badge.isHidden = viewModel.isBadgeHidden
    self.badge.configure(viewModel.badgeCount)
    if let attributeLastMessage = viewModel.attributeLastMessage {
      self.messageLabel.attributedText = attributeLastMessage
    } else {
      self.messageLabel.text = viewModel.lastMessage
    }
    self.messageLabel.numberOfLines = viewModel.isWelcome ?
      Constants.welcomeNumberOfLines :
      Constants.messageLabelNumberOfLines
    
    if let avatar = viewModel.avatar {
      self.avatarView.configure(avatar)
    } else {
      let channel = mainStore.state.channel
      self.avatarView.configure(channel)
    }
    
    self.messageLabel.textColor = viewModel.isClosed ? CHColors.blueyGrey : Color.messageLabel
  }
  
  static func calculateHeight(
    fits width: CGFloat,
    viewModel: UserChatCellModelType?) -> CGFloat {
    guard let viewModel = viewModel else { return 0 }
    let maxLines = viewModel.isWelcome ?
      Constants.welcomeNumberOfLines :
      Constants.messageLabelNumberOfLines
    var textHeight: CGFloat = 0
    if let attributedText = viewModel.attributeLastMessage {
      textHeight = attributedText.height(
        fits: width -
          Metrics.cellLeadingPadding -
          Metrics.avatarWidth -
          Metrics.avatarTrailingPadding -
          Metrics.messageLabelTrailingPadding,
        maximumNumberOfLines: maxLines
      )
    } else if let text = viewModel.lastMessage {
      textHeight = text.height(
        fits: width -
          Metrics.cellLeadingPadding -
          Metrics.avatarWidth -
          Metrics.avatarTrailingPadding -
          Metrics.messageLabelTrailingPadding,
        font: UIFont.systemFont(ofSize: 14),
        maximumNumberOfLines: maxLines
      )
    }
    
    var height: CGFloat = 0.0
    height += Metrics.cellTopPadding
    height += Metrics.titleHeight
    height += Metrics.messageLabelBottomPadding
    height += textHeight
    height += Metrics.messageLabelBottomPadding
    return viewModel.isWelcome ? max(Metrics.cellHeight, height) : Metrics.cellHeight
  }
  
  class func height(fits width: CGFloat, viewModel: UserChatCellModelType) -> CGFloat {
    return Metrics.cellHeight
  }
}
