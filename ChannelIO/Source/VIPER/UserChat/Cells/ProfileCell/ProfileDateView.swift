//
//  ProfileDateView.swift
//  ChannelIO
//
//  Created by 김진학 on 2020/07/23.
//  Copyright © 2020 ZOYI. All rights reserved.
//

final class ProfileDateView: ProfileItemBaseView, ProfileContentProtocol {
  private let dateView = DateActionView()
  var responder: UIView {
    return self.dateView.textField
  }
  var didFirstResponder: Bool = false
  
  override var fieldView: Actionable? {
    get {
      return self.dateView
    }
  }
  
  override func initialize() {
    super.initialize()
    self.dateView.setOutFocus()
  }
  
  override func setLayouts() {
    super.setLayouts()
  }
  
  override func configure(
    model: MessageCellModelType,
    index: Int?,
    presenter: UserChatPresenterProtocol?
  ) {
    super.configure(model: model, index: index, presenter: presenter)
    guard let item = self.item else { return }
    
    if let value = mainStore.state.user.profile?[item.key] as? Double {
      self.dateView.date = Date(timeIntervalSince1970: value / 1000)
    }
  }
}
