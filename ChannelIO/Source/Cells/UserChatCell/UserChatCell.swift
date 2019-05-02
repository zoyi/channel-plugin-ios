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

  // MARK: Constants

  struct Constant {
    static let titleLabelNumberOfLines = 1
    static let messageLabelNumberOfLines = 2
    static let timestampLabelNumberOfLines = 1
  }

  struct Metric {
    static let cellTopPadding = 13.f
    static let cellLeftPadding = 14.f
    static let cellRightPadding = 10.f
    static let titleBottomPadding = 7.f
    static let timestampBottomPadding = 13.f
    static let avatarRightPadding = 14.f
    static let avatarWidth = 36.f
    static let avatarHeight = 36.f
    static let badgeHeight = 22.f
    static let badgeLeftPadding = 20.f
    static let cellHeight = 80.f
  }

  struct Font {
    static let titleLabel = UIFont.boldSystemFont(ofSize: 14)
    static let messageLabel = UIFont.systemFont(ofSize: 14)
    static let timestampLabel = UIFont.systemFont(ofSize: 13)
  }

  struct Color {
    static let selectionColor = CHColors.snow
    static let titleLabel = CHColors.dark
    static let messageLabel = CHColors.dark
    static let timestampLabel = CHColors.gray
  }

  // MARK: Properties

  let bgView = UIView().then {
    $0.backgroundColor = Color.selectionColor
  }

  let titleLabel = UILabel().then {
    $0.font = Font.titleLabel
    $0.textColor = Color.titleLabel
    $0.numberOfLines = Constant.titleLabelNumberOfLines
  }

  let timestampLabel = UILabel().then {
    $0.font = Font.timestampLabel
    $0.textColor = Color.timestampLabel
    $0.textAlignment = .right
    $0.numberOfLines = Constant.timestampLabelNumberOfLines
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
    $0.numberOfLines = Constant.messageLabelNumberOfLines
  }

  // MARK: Initializing

  override func initialize() {
    self.selectedBackgroundView = self.bgView
    self.contentView.addSubview(self.titleLabel)
    self.contentView.addSubview(self.timestampLabel)
    self.contentView.addSubview(self.avatarView)
    self.contentView.addSubview(self.badge)
    self.contentView.addSubview(self.messageLabel)

    self.avatarView.snp.makeConstraints { (make) in
      make.top.equalToSuperview().inset(Metric.cellTopPadding)
      make.left.equalToSuperview().inset(Metric.cellLeftPadding)
      make.size.equalTo(CGSize(width: Metric.avatarWidth, height: Metric.avatarHeight))
    }
    
    self.titleLabel.snp.makeConstraints { [weak self] (make) in
      make.top.equalToSuperview().inset(Metric.cellTopPadding)
      make.left.equalTo((self?.avatarView.snp.right)!).offset(Metric.avatarRightPadding)
    }
    
    self.timestampLabel.snp.makeConstraints { [weak self] (make) in
      make.top.equalToSuperview().inset(Metric.cellTopPadding)
      make.right.equalToSuperview().inset(Metric.cellRightPadding)
      make.left.equalTo((self?.titleLabel.snp.right)!).offset(Metric.cellRightPadding)
    }
    
    self.messageLabel.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.titleLabel.snp.bottom)!).offset(Metric.titleBottomPadding)
      make.left.equalTo((self?.avatarView.snp.right)!).offset(Metric.avatarRightPadding)
      make.right.equalToSuperview().inset(76)
    }
    
    self.badge.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.timestampLabel.snp.bottom)!).offset(Metric.timestampBottomPadding)
      make.right.equalToSuperview().inset(Metric.cellRightPadding)
      make.height.equalTo(Metric.badgeHeight)
    }
  }

  // MARK: Configuring

  func configure(_ viewModel: UserChatCellModelType) {
    self.titleLabel.text = viewModel.title
    self.timestampLabel.text = viewModel.timestamp
    self.badge.isHidden = viewModel.isBadgeHidden
    self.badge.configure(viewModel.badgeCount)
    self.messageLabel.text = viewModel.lastMessage
    
    if let avatar = viewModel.avatar {
      self.avatarView.configure(avatar)
    } else {
      let channel = mainStore.state.channel
      self.avatarView.configure(channel)
    }
    
    self.messageLabel.textColor = viewModel.isClosed ?
      CHColors.blueyGrey :  Color.messageLabel
  }

  // MARK: Cell Height

  func height(fits width: CGFloat, viewModel: UserChatCellModelType?) -> CGFloat {
    guard let viewModel = viewModel else { return 0 }
    
    var height: CGFloat = 0.0
    height += 13.f //top
    height += 18.f
    height += viewModel.lastMessage?.height(fits: width - 62.f - 52.f, font: UIFont.systemFont(ofSize: 14)) ?? 0
    height += 9
    return 0
  }
  
  class func height(fits width: CGFloat, viewModel: UserChatCellModelType) -> CGFloat {
    return Metric.cellHeight
  }
}
