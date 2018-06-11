//
//  TokenView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 11/06/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit

enum ActionAlignment {
  case left
  case right
}

class ActionButton: UIButton {
  var value: CHi18n? = nil
  var key: String = ""
  var selectedColor: UIColor? = nil
  var selectedTextColor: UIColor? = nil {
    didSet {
      self.setTitleColor(selectedTextColor, for: .highlighted)
    }
  }
  
  override open var isHighlighted: Bool {
    didSet {
      self.backgroundColor = isHighlighted ? selectedColor : UIColor.white
    }
  }
  
  struct Constant {
    static let maxWidth = UIScreen.main.bounds.width - 10.f - 65.f
  }
  
  
  required init(input: CHInput) {
    super.init(frame: CGRect.zero)
    self.value = input.value
    self.key = input.key
    
    let text = self.value?.getMessage() ?? ""
    self.titleLabel?.numberOfLines = 2
    self.titleEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    self.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    self.setTitle(text, for: .normal)
    self.setTitleColor(CHColors.dark80, for: .normal)
 
    self.layer.cornerRadius = 15.f
    self.layer.borderWidth = 1.f
    self.layer.borderColor = CHColors.dark80.cgColor
    
    let size = text.size(
      fits: CGSize(width: Constant.maxWidth, height: 10000),
      font: UIFont.systemFont(ofSize: 15),
      maximumNumberOfLines: 2)
    
    self.width = size.width + 24
    self.height = size.height + 20
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class ActionView: BaseView {
  var buttons: [ActionButton] = []
  var contentView = UIView()
  var alignment: ActionAlignment = .right
  var actionSubject = PublishSubject<ActionKey>()
  
  struct Constant {
    static let maxWidth = UIScreen.main.bounds.width - 10.f - 65.f
  }
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.contentView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.contentView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
  }
  
  func configure(_ viewModel: MessageCellModelType) {
    for view in self.contentView.subviews {
      view.removeFromSuperview()
    }
    self.buttons.removeAll()
    
    guard viewModel.shouldDisplayActions else { return }
    guard let inputs = viewModel.message.form?.inputs else { return }
    
    for input in inputs {
      let button = ActionButton(input: input)
      button.selectedColor = viewModel.pluginColor
      button.selectedTextColor = viewModel.textColor
      
      self.contentView.addSubview(button)
      self.buttons.append(button)
      _ = button.signalForClick().subscribe(onNext: { [weak self] (_) in
        self?.actionSubject.onNext(button.key)
      })
    }
    
    //layouts them based on width
    var cx = 0.f, cy = 0.f, rowCount = 0, totalCount = 0
    let maxWidth = UIScreen.main.bounds.width - 75.f
    var lastRowCount = 0
    
    for (index, button) in self.buttons.enumerated() {
      rowCount += 1
      totalCount += 1
      if maxWidth < cx + button.width {
        cy += button.height + 4.f
        cx = 0.f
        button.origin = CGPoint(x: cx, y: cy)
        
        if self.alignment == .right {
          let buttons = Array(self.buttons[totalCount-rowCount..<index])
          self.realignItemsToRight(buttons: buttons)
        }
        
        lastRowCount = rowCount - 1
        rowCount = 0
      } else {
        button.origin = CGPoint(x: cx, y: cy)
        cx += button.width + 4.f
        lastRowCount = rowCount
      }
    }
    
    if self.alignment == .right {
      let buttons = Array(self.buttons[totalCount-lastRowCount..<self.buttons.count])
      self.realignItemsToRight(buttons: buttons)
    }
  }
  
  private func realignItemsToRight(buttons: [ActionButton]) {
    let leftOverMargin =  UIScreen.main.bounds.width - 10 - (buttons.last?.origin.x ?? 0) - (buttons.last?.width ?? 0)
    guard  leftOverMargin > 0 else { return }
    
    for button in buttons {
      button.origin = CGPoint(x: button.origin.x + leftOverMargin, y: button.origin.y)
    }
  }

  func observeAction() -> Observable<ActionKey> {
    return self.actionSubject.asObservable()
  }
  
  class func viewHeight(fits width: CGFloat, inputs: [CHInput]) -> CGFloat {
    var cx = 0.f, cy = 0.f

    for (index, input) in inputs.enumerated() {
      let size = input.value?.getMessage()?.size(
        fits: CGSize(width: Constant.maxWidth, height: 10000),
        font: UIFont.systemFont(ofSize: 15),
        maximumNumberOfLines: 2) ?? CGSize.zero
      
      if index == 0 {
        cy = size.height + 20.f + 4.f
      }
      
      if Constant.maxWidth < cx + size.width { //not fit
        cy += size.height + 20.f + 4.f
        cx = 0.f //default
      } else {
        cx += size.width + 4.f
      }
    }
    return cy + 3
  }
}

