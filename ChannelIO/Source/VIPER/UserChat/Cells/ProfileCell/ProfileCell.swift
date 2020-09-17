//
//  ProfileCell.swift
//  ChannelIO
//
//  Created by R3alFr3e on 4/11/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit
import RxSwift

protocol Actionable: class {
  func signalForAction() -> Observable<Any?>
  func signalForText() -> Observable<String?>?
  func signalForFocus() -> Observable<Bool>
  func setLoading()
  func setFocus()
  func setOutFocus()
  func setInvalid()
  
  var didFocus: Bool { get set }
  var view: UIView { get }
}

extension Actionable where Self: UIView {
  var view: UIView { return self }
}

protocol ProfileContentProtocol: class {
  var view: UIView { get }
  var responder: UIView { get }
  var didFirstResponder: Bool { get }
}

extension ProfileContentProtocol where Self: UIView {
  var view: UIView { return self }
}

enum ProfileInputType {
  case text
  case email
  case number
  case mobileNumber
}

class ProfileMessageCell : MessageCell {
  private struct ProfileMetrics {
    static let viewTop = 20.f
    static let viewLeading = 26.f
    static let viewTrailing = 26.f
    static let viewBottom = 5.f
    static let shadowHeight = 3.f
  }
  
  let profileExtendableView = ProfileExtendableView()
  
  override func initialize() {
    super.initialize()
    self.contentView.layer.masksToBounds = false
    self.contentView.addSubview(self.profileExtendableView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.messageBottomConstraint?.deactivate()
    
    self.profileExtendableView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(ProfileMetrics.viewTop)
      make.left.equalToSuperview().inset(ProfileMetrics.viewLeading)
      make.right.equalToSuperview().inset(ProfileMetrics.viewTrailing)
      make.bottom.equalToSuperview().inset(ProfileMetrics.shadowHeight)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  override func configure(
    _ viewModel: MessageCellModelType,
    dataSource: (UITableViewDataSource & UITableViewDelegate),
    presenter: UserChatPresenterProtocol? = nil,
    row: Int = 0) {
    super.configure(viewModel, dataSource: dataSource, presenter: presenter, row: row)
    self.profileExtendableView.configure(
      model: viewModel,
      presenter: presenter,
      redraw: presenter?.shouldRedrawProfileBot ?? false
    )
    
    self.profileExtendableView.snp.remakeConstraints { make in
      if viewModel.text != nil || viewModel.showTranslation {
        make.top.equalTo(self.translateView.snp.bottom).offset(ProfileMetrics.viewTop)
      } else if viewModel.isContinuous {
        make.top.equalToSuperview().inset(ProfileMetrics.viewTop)
      } else {
        make.top.equalTo(self.usernameLabel.snp.bottom).offset(ProfileMetrics.viewTop)
      }
      make.left.equalToSuperview().inset(ProfileMetrics.viewLeading)
      make.right.equalToSuperview().inset(ProfileMetrics.viewTrailing)
      make.bottom.equalToSuperview().inset(ProfileMetrics.shadowHeight)
    }
  }
  
  override class func cellHeight(
    fits width: CGFloat,
    viewModel: MessageCellModelType) -> CGFloat {
    var height = super.cellHeight(fits: width, viewModel: viewModel)
    height += ProfileMetrics.viewTop
    height += ProfileExtendableView.viewHeight(
      fit: width - ProfileMetrics.viewLeading - ProfileMetrics.viewTrailing,
      model: viewModel)
    return height + ProfileMetrics.shadowHeight
  }
}

class ProfileWebMessageCell : WebPageMessageCell {
  struct Metric {
    static let viewTop = 20.f
    static let viewLeading = 26.f
    static let viewTrailing = 26.f
    static let viewBottom = 5.f
    static let shadowHeight = 3.f
  }
  
  let profileExtendableView = ProfileExtendableView()
  
  override func initialize() {
    super.initialize()
    self.contentView.layer.masksToBounds = false
    self.contentView.addSubview(self.profileExtendableView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.messageBottomConstraint?.deactivate()
    self.webBottomConstraint?.deactivate()
    
    self.profileExtendableView.snp.makeConstraints { make in
      make.top.equalTo(self.webView.snp.bottom).offset(Metric.viewTop)
      make.left.equalToSuperview().inset(Metric.viewLeading)
      make.right.equalToSuperview().inset(Metric.viewTrailing)
      make.bottom.equalToSuperview().inset(Metric.shadowHeight)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  override func configure(
    _ viewModel: MessageCellModelType,
    dataSource: (UITableViewDataSource & UITableViewDelegate),
    presenter: UserChatPresenterProtocol? = nil,
    row: Int = 0) {
    super.configure(viewModel, dataSource: dataSource, presenter: presenter, row: row)
    self.profileExtendableView.configure(
      model: viewModel,
      presenter: presenter,
      redraw: presenter?.shouldRedrawProfileBot ?? false
    )
  }
  
  override class func cellHeight(
    fits width: CGFloat,
    viewModel: MessageCellModelType) -> CGFloat {
    var height = super.cellHeight(fits: width, viewModel: viewModel)
    height += Metric.viewTop
    height += ProfileExtendableView.viewHeight(
      fit: width - Metric.viewLeading - Metric.viewTrailing,
      model: viewModel)
    return height + Metric.shadowHeight
  }
}

class ProfileMediaMessageCell : MediaMessageCell {
  struct Metric {
    static let viewTop = 20.f
    static let viewLeading = 26.f
    static let viewTrailing = 26.f
    static let viewBottom = 5.f
    static let shadowHeight = 3.f
  }
  
  let profileExtendableView = ProfileExtendableView()
  var topToMessageConstraint: Constraint?
  var topToWebConstraint: Constraint?
  
  override func initialize() {
    super.initialize()
    self.contentView.layer.masksToBounds = false
    self.contentView.addSubview(self.profileExtendableView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.messageBottomConstraint?.deactivate()
    self.mediaViewBottomConstraint?.deactivate()
    
    self.profileExtendableView.snp.makeConstraints { make in
      make.top.equalTo(self.mediaCollectionView.snp.bottom).offset(Metric.viewTop)
      make.left.equalToSuperview().inset(Metric.viewLeading)
      make.right.equalToSuperview().inset(Metric.viewTrailing)
      make.bottom.equalToSuperview().inset(Metric.shadowHeight)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  override func configure(
    _ viewModel: MessageCellModelType,
    dataSource: (UITableViewDataSource & UITableViewDelegate),
    presenter: UserChatPresenterProtocol? = nil,
    row: Int = 0) {
    super.configure(viewModel, dataSource: dataSource, presenter: presenter, row: row)
    self.profileExtendableView.configure(
      model: viewModel,
      presenter: presenter,
      redraw: presenter?.shouldRedrawProfileBot ?? false
    )
  }
  
  override class func cellHeight(
    fits width: CGFloat,
    viewModel: MessageCellModelType) -> CGFloat {
    var height = super.cellHeight(fits: width, viewModel: viewModel)
    height += Metric.viewTop
    height += ProfileExtendableView.viewHeight(
      fit: width - Metric.viewLeading - Metric.viewTrailing,
      model: viewModel)
    return height + Metric.shadowHeight
  }
}
