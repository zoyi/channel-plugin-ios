//
//  MessageCell.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 9..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import Reusable
import SnapKit

final class MessageCell: BaseTableViewCell, Reusable {

  // MARK: Constants

  struct Constant {

  }
  
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
    static let avatarWidth = 24.f
    static let avatarRightPadding = 6.f
    static let bubbleLeftMargin = Metric.cellLeftPadding + Metric.avatarWidth + Metric.avatarRightPadding
    static let usernameHeight = 15.f
    static let cellTopPaddingOfContinous = 3.f
    static let cellTopPaddingDefault = 16.f
    static let messageCellMinMargin = 105.f
  }
  
  // MARK: Properties
  var clipView: UIView? = nil
  
  let avatarView = AvatarView().then {
    $0.showBorder = false
    $0.showOnline = false 
    $0.initialLabel.font = UIFont.boldSystemFont(ofSize: 12)
    $0.layer.cornerRadius = 12.f
  }
  
  let usernameLabel = UILabel().then {
    $0.font = Font.usernameLabel
    $0.textColor = Color.username
  }
  
  let timestampLabel = UILabel().then {
    $0.font = Font.timestampLabel
    $0.textColor = Color.timestamp
  }
  
  let bubbleView = CHMBubbleView()

  //TODO: refactor different message cell types (image, file, web)
  let clipFileView = CHMFileView().then {
    $0.isHidden = true
  }
  
  let clipWebpageView = CHMWebpageView().then {
    $0.isHidden = true
  }
  
  let clipImageView = CHMImageView().then {
    $0.contentMode = UIViewContentMode.scaleAspectFill
    $0.isHidden = true
  }

  let resendButtonView = UIButton().then {
    $0.setImage(CHAssets.getImage(named: "resend"), for: .normal)
  }

  var viewModel: MessageCellModelType?
  // MARK: Initializing

  override func initialize() {
    super.initialize()

    self.contentView.addSubview(self.avatarView)
    self.contentView.addSubview(self.usernameLabel)
    self.contentView.addSubview(self.timestampLabel)
    self.contentView.addSubview(self.bubbleView)
    self.contentView.addSubview(self.clipFileView)
    self.contentView.addSubview(self.clipWebpageView)
    self.contentView.addSubview(self.clipImageView)
    self.contentView.addSubview(self.resendButtonView)

    self.resendButtonView.signalForClick()
      .subscribe(onNext: { [weak self] _ in
      self?.showPicker()
    }).disposed(by :self.disposeBag)
  }

  // MARK: Configuring

  func configure(_ viewModel: MessageCellModelType) {
    self.viewModel = viewModel

    self.resendButtonView.isHidden = !viewModel.isFailed

    self.setTexts(viewModel)
    self.setMessageDeco(viewModel)
    self.setClipIfNeed(viewModel)
    
    self.setNeedsLayout()
    self.layoutIfNeeded()
  }

  
  // MARK: Cell Height

  class func measureHeight(fits width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
    var viewHeight : CGFloat = 0.0
    
    if viewModel.isContinuous == true {
      viewHeight += Metric.cellTopPaddingOfContinous
    } else {
      viewHeight += Metric.cellTopPaddingDefault + Metric.usernameHeight + 4
    }

    let bubbleMaxWidth = viewModel.createdByMe ?
      width - Metric.messageCellMinMargin - Metric.cellRightPadding :
      width - Metric.messageCellMinMargin - Metric.bubbleLeftMargin

    //bubble height
    if viewModel.message.message != "" {
      viewHeight += CHMBubbleView.measureHeight(fits: bubbleMaxWidth, viewModel: viewModel)
    }
    
    //clip height
    if viewModel.file != nil || viewModel.webpage != nil {
      viewHeight += 3
      if viewModel.file?.image == false {
        viewHeight += CHMFileView.Metric.HEIGHT
      } else if viewModel.file?.image == true {
        viewHeight += CHMImageView.measureSize(fits: bubbleMaxWidth, viewModel: viewModel).height
      } else if viewModel.webpage != nil {
        viewHeight += CHMWebpageView.measureHeight(fits: bubbleMaxWidth, webpage: viewModel.webpage!)
      }
    }

    return viewHeight
  }
  
  // MARK: helpers

  func setTexts(_ viewModel: MessageCellModelType) {
    self.usernameLabel.text = viewModel.name
    self.timestampLabel.text = viewModel.timestamp
    self.timestampLabel.isHidden = viewModel.timestampIsHidden
  }
  
  func setMessageDeco(_ viewModel: MessageCellModelType) {
    self.avatarView.configure(viewModel.avatarEntity)
    self.avatarView.isHidden = viewModel.avatarIsHidden
    self.usernameLabel.isHidden = viewModel.usernameIsHidden
    self.bubbleView.configure(viewModel)
  }
  
  func setClipIfNeed(_ viewModel: MessageCellModelType) {
    self.clipImageView.isHidden = viewModel.imageIsHidden
    self.clipFileView.isHidden = viewModel.fileIsHidden
    self.clipWebpageView.isHidden = viewModel.webpageIsHidden

    if viewModel.imageIsHidden == false {
      self.clipImageView.configure(message: viewModel, isThumbnail: true)
      self.clipView = self.clipImageView
    } else if viewModel.fileIsHidden == false {
      self.clipFileView.configure(message: viewModel)
      self.clipView = self.clipFileView
    } else if viewModel.webpageIsHidden == false {
      self.clipWebpageView.configure(message: viewModel)
      self.clipView = self.clipWebpageView
    } else {
      
      self.clipView = nil
    }
  }

  private func showPicker() {
    let alertView = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
    alertView.addAction(UIAlertAction(title: CHAssets.localized("ch.chat.retry_sending_message"), style: .default) { [weak self] _ in
      self?.viewModel?.message.send().subscribe(onNext: { (message) in
        mainStore.dispatch(CreateMessage(payload: message))
      }).disposed(by: (self?.disposeBag)!)
    })

    alertView.addAction(UIAlertAction(title: CHAssets.localized("ch.chat.delete"), style: .destructive) { [weak self] _ in
      mainStore.dispatch(DeleteMessage(payload: (self?.viewModel?.message)!))
    })

    alertView.addAction(UIAlertAction(title: CHAssets.localized("ch.chat.resend.cancel"), style: .cancel) { _ in
      // no action
    })

    CHUtils.getTopController()?.present(alertView, animated: true, completion: nil)
  }

  // MARK: Layout
  
  override func layoutSubviews() {
    super.layoutSubviews()

    self.layoutUserInfo()
    self.layoutClip()
    self.layoutResend()
  }
}

// MARK: layout
extension MessageCell {
  func layoutUserInfo() {
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
    self.bubbleView.snp.remakeConstraints({ [weak self] (make) in
      make.left.greaterThanOrEqualToSuperview().inset(Metric.messageCellMinMargin)
      make.right.equalToSuperview().inset(Metric.cellRightPadding)
      if self?.bubbleView.messageView.text == "" {
        make.top.equalToSuperview()
      } else {
        make.top.equalToSuperview().inset(Metric.cellTopPaddingOfContinous)
      }
    })
  }
  
  func layoutDefaultByMe() {
    self.timestampLabel.snp.remakeConstraints({ (make) in
      make.trailing.equalToSuperview().inset(Metric.cellRightPadding)
      make.top.equalToSuperview().inset(Metric.cellTopPaddingDefault)
    })
    self.usernameLabel.snp.remakeConstraints({ [weak self] (make) in
      make.left.equalTo((self?.avatarView.snp.right)!).offset(0)
      make.top.equalTo((self?.avatarView.snp.top)!)
    })
    self.bubbleView.snp.remakeConstraints({ [weak self] (make) in
      make.left.greaterThanOrEqualToSuperview().inset(Metric.messageCellMinMargin)
      make.right.equalToSuperview().inset(Metric.cellRightPadding)
      if self?.bubbleView.messageView.text == "" {
        make.top.equalTo((self?.timestampLabel.snp.bottom)!)
      } else {
        make.top.equalTo((self?.timestampLabel.snp.bottom)!).offset(4)
      }
    })
  }
  
  func layoutContinuousByOther() {
    self.avatarView.snp.remakeConstraints({ make in
      make.leading.equalToSuperview().offset(Metric.cellLeftPadding)
      make.top.equalToSuperview().inset(Metric.cellTopPaddingOfContinous)
      make.size.equalTo(CGSize(width: Metric.avatarWidth, height: Metric.avatarWidth))
    })
    self.usernameLabel.snp.remakeConstraints({ [weak self] (make) in
      make.left.equalTo((self?.avatarView.snp.right)!).offset(8)
      make.top.equalTo((self?.avatarView.snp.top)!)
      make.height.equalTo(Metric.usernameHeight)
    })
    self.timestampLabel.snp.remakeConstraints({ [weak self] (make) in
      make.left.equalTo((self?.usernameLabel.snp.right)!).offset(6)
      make.centerY.equalTo((self?.usernameLabel)!)
    })
    self.bubbleView.snp.remakeConstraints({ [weak self] (make) in
      make.left.equalToSuperview().inset(Metric.bubbleLeftMargin)
      make.right.lessThanOrEqualToSuperview().inset(Metric.messageCellMinMargin)
      if self?.bubbleView.messageView.text == "" {
        make.top.equalToSuperview()
      } else {
        make.top.equalToSuperview().inset(Metric.cellTopPaddingOfContinous)
      }
    })
  }
  
  func layoutDefaultByOther() {
    self.avatarView.snp.remakeConstraints({ make in
      make.leading.equalToSuperview().offset(Metric.cellLeftPadding)
      make.top.equalToSuperview().inset(Metric.cellTopPaddingDefault)
      make.size.equalTo(CGSize(width: Metric.avatarWidth, height: Metric.avatarWidth))
    })
    self.usernameLabel.snp.remakeConstraints({ [weak self] (make) in
      make.left.equalTo((self?.avatarView.snp.right)!).offset(8)
      make.top.equalTo((self?.avatarView.snp.top)!)
      make.height.equalTo(Metric.usernameHeight)
    })
    self.timestampLabel.snp.remakeConstraints({ [weak self] (make) in
      make.left.equalTo((self?.usernameLabel.snp.right)!).offset(6)
      make.centerY.equalTo((self?.usernameLabel)!)
    })
    self.bubbleView.snp.remakeConstraints({ [weak self] (make) in
      make.left.equalToSuperview().inset(Metric.bubbleLeftMargin)
      make.right.lessThanOrEqualToSuperview().inset(Metric.messageCellMinMargin)
      if self?.bubbleView.messageView.text == "" {
        make.top.equalTo((self?.usernameLabel.snp.bottom)!)
      } else {
        make.top.equalTo((self?.usernameLabel.snp.bottom)!).offset(4)
      }
    })
  }

  func layoutClip() {
    self.clipFileView.snp.remakeConstraints({ [weak self] (make) in
      if self?.clipFileView.isHidden == true {
        make.height.equalTo(0)
        return
      }
      make.height.equalTo(CHMFileView.Metric.HEIGHT)
      make.top.equalTo((self?.bubbleView.snp.bottom)!).offset(3)
      if self?.viewModel?.createdByMe == true {
        make.right.equalToSuperview().inset(Metric.cellRightPadding)
        make.left.equalToSuperview().inset(Metric.messageCellMinMargin)
      } else {
        make.right.equalToSuperview().inset(Metric.messageCellMinMargin)
        make.left.equalToSuperview().inset(Metric.bubbleLeftMargin)
      }
    })
    
    self.clipWebpageView.snp.remakeConstraints({ [weak self] (make) in
      if self?.clipWebpageView.isHidden == true {
        make.height.equalTo(0)
        return
      }
      
      let height = CHMWebpageView.measureHeight(fits: (self?.width)!, webpage: self?.viewModel?.webpage)
      make.height.equalTo(height)
      
      make.top.equalTo((self?.bubbleView.snp.bottom)!).offset(3)
      if self?.viewModel?.createdByMe == true {
        make.right.equalToSuperview().inset(Metric.cellRightPadding)
        make.left.equalToSuperview().inset(Metric.messageCellMinMargin)
      } else {
        make.right.equalToSuperview().inset(Metric.messageCellMinMargin)
        make.left.equalToSuperview().inset(Metric.bubbleLeftMargin)
      }
      make.bottom.equalToSuperview()
    })
    
    self.clipImageView.snp.remakeConstraints({ [weak self] (make) in
      if self?.clipImageView.isHidden == true {
        make.height.equalTo(0)
        return
      }
      make.size.equalTo(CHMImageView.measureSize(fits: (self?.width)!, viewModel: (self?.viewModel)!))
      make.top.equalTo((self?.bubbleView.snp.bottom)!).offset(3)
      if self?.viewModel?.createdByMe == true {
        make.right.equalToSuperview().inset(Metric.cellRightPadding)
      } else {
        make.left.equalToSuperview().inset(Metric.bubbleLeftMargin)
      }
    })
  }

  func layoutResend() {
    self.resendButtonView.snp.remakeConstraints({ [weak self] (make) in
      make.size.equalTo(CGSize(width: 40, height: 40))
      if self?.viewModel?.createdByMe == true {
        if self?.clipView?.isHidden == true || self?.clipView == nil {
          make.bottom.equalTo((self?.bubbleView.snp.bottom)!)
          make.right.equalTo((self?.bubbleView.snp.left)!).inset(4)
        } else if self?.clipView != nil {
          make.bottom.equalTo((self?.clipView?.snp.bottom)!)
          make.right.equalTo((self?.clipView?.snp.left)!).inset(4)
        }
      }
    })
  }
}
