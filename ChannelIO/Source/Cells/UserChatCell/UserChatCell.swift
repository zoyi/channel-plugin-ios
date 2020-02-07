//
//  UserChatCell.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 14..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import SnapKit

final class UserChatCell: BaseTableViewCell {

  // MARK: Constantss

  struct Constants {
    static let titleLabelNumberOfLines = 1
    static let messageLineWithFile = 1
    static let messageLineWithoutFile = 2
    static let timestampLabelNumberOfLines = 1
  }

  struct Metrics {
    static let cellTopPadding = 13.f
    static let cellLeftPadding = 14.f
    static let cellRightPadding = 15.f
    static let titleBottomPadding = 4.f
    static let timestampBottomPadding = 13.f
    static let timestampLeftPadding = 10.f
    static let avatarRightPadding = 14.f
    static let avatarSide = 36.f
    static let badgeHeight = 22.f
    static let badgeLeftPadding = 20.f
    static let messageTrailing = 58.f
    static let cellHeight = 80.f
    static let fileHeight = 18.f
    static let welcomeBottom = 10.f
    static let messageLineHeight = 18.f
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

  // MARK: Properties

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
  
  let contentStackView = UIStackView().then {
    $0.axis = .vertical
  }
  
  let fileInfoView = AttachmentFileInfoView()

  let badge = Badge().then {
    $0.minWidth = 12.f
  }

  let messageLabel = UILabel().then {
    $0.font = Font.messageLabel
    $0.textColor = Color.messageLabel
    $0.numberOfLines = Constants.messageLineWithoutFile
  }
  
  // MARK: Initializing

  override func initialize() {
    self.selectedBackgroundView = self.bgView
    self.contentView.addSubview(self.titleLabel)
    self.contentView.addSubview(self.timestampLabel)
    self.contentView.addSubview(self.avatarView)
    self.contentView.addSubview(self.badge)
    self.contentStackView.addArrangedSubview(self.messageLabel)
    self.contentStackView.addArrangedSubview(self.fileInfoView)
    self.contentView.addSubview(self.contentStackView)
    
    self.avatarView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(Metrics.cellTopPadding)
      make.left.equalToSuperview().inset(Metrics.cellLeftPadding)
      make.width.height.equalTo(Metrics.avatarSide)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(Metrics.cellTopPadding)
      make.left.equalTo(self.avatarView.snp.right).offset(Metrics.avatarRightPadding)
      
    }
    
    self.timestampLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(Metrics.cellTopPadding)
      make.right.equalToSuperview().inset(Metrics.cellRightPadding)
      make.left.equalTo(self.titleLabel.snp.right).offset(Metrics.timestampLeftPadding)
    }
    
    self.contentStackView.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(Metrics.titleBottomPadding)
      make.left.equalTo(self.avatarView.snp.right).offset(Metrics.avatarRightPadding)
      make.right.equalToSuperview().inset(Metrics.messageTrailing)
      make.bottom.lessThanOrEqualToSuperview()
    }
    
    self.badge.snp.makeConstraints { make in
      make.top.equalTo(self.timestampLabel.snp.bottom)
        .offset(Metrics.timestampBottomPadding)
      make.right.equalToSuperview().inset(Metrics.cellRightPadding)
      make.height.equalTo(Metrics.badgeHeight)
    }
  }

  func configure(_ viewModel: UserChatCellModelType) {
    self.titleLabel.text = viewModel.title
    self.timestampLabel.text = viewModel.timestamp
    self.badge.isHidden = viewModel.isBadgeHidden
    self.badge.configure(viewModel.badgeCount)
    self.messageLabel.attributedText = viewModel.lastMessage?.addLineHeight(
      height: Metrics.messageLineHeight,
      font: Font.messageLabel,
      color: viewModel.isClosed ? CHColors.blueyGrey : Color.messageLabel
    )
    self.messageLabel.isHidden = !(viewModel.lastMessage != nil)
    let hasFiles = viewModel.files.count > 0
    self.fileInfoView.isHidden = !hasFiles
    self.fileInfoView.configure(with: viewModel.files, isLarge: false)
    
    self.messageLabel.numberOfLines = hasFiles ?
      Constants.messageLineWithFile :
      Constants.messageLineWithoutFile

    self.avatarView.configure(viewModel.avatar ?? mainStore.state.channel)
  }

  static func calculateHeight(
    fits width: CGFloat,
    viewModel: UserChatCellModelType?,
    maxNumberOfLines: Int) -> CGFloat {
    guard let viewModel = viewModel else { return 0 }
    
    var height: CGFloat = 0.0
    height += Metrics.cellTopPadding
    height += viewModel.title.height(
      fits: width
        - Metrics.cellLeftPadding
        - Metrics.avatarSide
        - Metrics.avatarRightPadding
        - Metrics.messageTrailing,
      font: Font.titleLabel,
      maximumNumberOfLines: Constants.titleLabelNumberOfLines
    )
    height += Metrics.titleBottomPadding
    let hasFiles = viewModel.files.count > 0
    let text = viewModel.lastMessage?.addLineHeight(
      height: Metrics.messageLineHeight,
      font: Font.messageLabel,
      color: viewModel.isClosed ? CHColors.blueyGrey : Color.messageLabel
    )
    height += text?.height(
      fits: width
        - Metrics.cellLeftPadding
        - Metrics.avatarSide
        - Metrics.avatarRightPadding
        - Metrics.messageTrailing,
      maximumNumberOfLines: maxNumberOfLines
    ) ?? 0
    height += hasFiles ? Metrics.fileHeight : 0
    height += Metrics.welcomeBottom
    
    return height
  }
  
  class func height(
    fits width: CGFloat,
    viewModel: UserChatCellModelType) -> CGFloat {
    return Metrics.cellHeight
  }
}
