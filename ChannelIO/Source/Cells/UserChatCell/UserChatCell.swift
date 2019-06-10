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

  // MARK: Constantss

  struct Constants {
    static let titleLabelNumberOfLines = 1
    static let messageLabelNumberOfLines = 2
    static let timestampLabelNumberOfLines = 1
  }

  struct Metrics {
    static let cellTopPadding = 13.f
    static let cellLeftPadding = 14.f
    static let cellRightPadding = 15.f
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

    self.avatarView.snp.makeConstraints { (make) in
      make.top.equalToSuperview().inset(Metrics.cellTopPadding)
      make.left.equalToSuperview().inset(Metrics.cellLeftPadding)
      make.size.equalTo(CGSize(width: Metrics.avatarWidth, height: Metrics.avatarHeight))
    }
    
    self.titleLabel.snp.makeConstraints { [weak self] (make) in
      make.top.equalToSuperview().inset(Metrics.cellTopPadding)
      make.left.equalTo((self?.avatarView.snp.right)!).offset(Metrics.avatarRightPadding)
    }
    
    self.timestampLabel.snp.makeConstraints { [weak self] (make) in
      make.top.equalToSuperview().inset(Metrics.cellTopPadding)
      make.right.equalToSuperview().inset(Metrics.cellRightPadding)
      make.left.equalTo((self?.titleLabel.snp.right)!).offset(Metrics.cellRightPadding)
    }
    
    self.messageLabel.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.titleLabel.snp.bottom)!).offset(Metrics.titleBottomPadding)
      make.left.equalTo((self?.avatarView.snp.right)!).offset(Metrics.avatarRightPadding)
      make.right.equalToSuperview().inset(76)
    }
    
    self.badge.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.timestampLabel.snp.bottom)!).offset(Metrics.timestampBottomPadding)
      make.right.equalToSuperview().inset(Metrics.cellRightPadding)
      make.height.equalTo(Metrics.badgeHeight)
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

  static func calculateHeight(fits width: CGFloat, viewModel: UserChatCellModelType?, maxNumberOfLines: Int) -> CGFloat {
    guard let viewModel = viewModel else { return 0 }
    
    var height: CGFloat = 0.0
    height += 13.f //top
    height += 18.f
    height += viewModel.lastMessage?
      .height(
        fits: width - 62.f - 52.f,
        font: UIFont.systemFont(ofSize: 14),
        maximumNumberOfLines: maxNumberOfLines
      ) ?? 0
    height += 9
    return height
  }
  
  class func height(fits width: CGFloat, viewModel: UserChatCellModelType) -> CGFloat {
    return Metrics.cellHeight
  }
}
