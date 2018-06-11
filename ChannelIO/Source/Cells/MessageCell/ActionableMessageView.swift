//
//  ActionableMessageView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 08/06/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

typealias ActionKey = String

//class ActionableMessageView: BaseView {
//  var actionField = ActionField()
//  var actions: [CHInput] = []
//  var actionSubject = PublishSubject<CHInput>()
//  
//  override func initialize() {
//    super.initialize()
//    
//    self.addSubview(self.actionField)
//  }
//  
//  override func setLayouts() {
//    super.setLayouts()
//    
//    self.actionField.snp.makeConstraints { (make) in
//      make.edges.equalToSuperview()
//    }
//  }
//  
//  func configure(viewModel: MessageCellModelType) {
//    self.actions = viewModel.message.form?.inputs ?? []
//    self.actionField.reloadData()
//  }
//  
//  func observeAction() -> Observable<CHInput> {
//    return self.actionSubject.asObservable()
//  }
//  
//  static func viewHeight(fit width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
//    return 0
//  }
//}

//extension ActionableMessageView: ActionFieldDataSource, ActionFieldDelegate {
//  func lineHeightForActionInField(_ actionField: ActionField) -> CGFloat {
//    return 0
//  }
//
//  func numberOfActionInField(_ actionField: ActionField) -> Int {
//    return self.actions.count
//  }
//
//  func actionField(_ actionField: ActionField, viewForActionAt index: Int) -> UIView {
//    let actionData = self.actions[index]
//    let button = ActionButton(input: actionData)
//
//    return button
//  }
//
//  func actionMarginInActionField(_ actionField: ActionField) -> CGFloat {
//    return 5.f
//  }
//
//  func didSelectAt(_ actionField: ActionField, index: Int) {
//    let actionData = self.actions[index]
//    self.actionSubject.onNext(actionData)
//  }
//}
