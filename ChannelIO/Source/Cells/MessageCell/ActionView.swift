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

typealias ActionKey = String

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
  
  override var isSelected: Bool {
    didSet {
      self.backgroundColor = isHighlighted ? selectedColor : UIColor.white
    }
  }
  
  struct Metric {
    static let topBottomMargin = 10.f
    static let sideMargin = 12.f
  }
  
  struct Constant {
    static let maxWidth = UIScreen.main.bounds.width - 10.f - 65.f
  }
  
  required init(input: CHInput) {
    super.init(frame: CGRect.zero)
    self.value = input.value
    self.key = input.key
    
    let text = self.value?.getMessage() ?? ""
    self.setTitle(text, for: .normal)
    self.titleLabel?.lineBreakMode = .byTruncatingTail
    self.titleLabel?.numberOfLines = 2
    self.titleEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    self.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    self.titleLabel?.preferredMaxLayoutWidth = Constant.maxWidth
    self.setTitleColor(CHColors.dark80, for: .normal)
 
    self.layer.cornerRadius = 15.f
    self.layer.borderWidth = 1.f
    self.layer.borderColor = CHColors.dark80.cgColor
    
    let size = text.size(
      fits: CGSize(width: Constant.maxWidth, height: 10000),
      font: UIFont.systemFont(ofSize: 15),
      maximumNumberOfLines: 2)
    
    self.frame = CGRect(x: 0, y: 0,
        width: size.width + Metric.sideMargin * 2,
        height: size.height + Metric.topBottomMargin * 2)
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
  
  struct Metric {
    static let itemBetweenMargin = 4.f
    static let topBottomMargin = 10.f
    static let sideMargin = 12.f
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
    var lastRowCount = 0
    var lastButton: ActionButton!
    
    for (index, button) in self.buttons.enumerated() {
      rowCount += 1
      totalCount += 1
      if Constant.maxWidth < cx + button.width {
        let calcualtedY = lastButton.origin.y + lastButton.frame.height + 4.f
        button.origin = CGPoint(x: 0.f, y: calcualtedY)
        
        if self.alignment == .right {
          let buttons = Array(self.buttons[totalCount-rowCount..<index])
          self.realignItemsToRight(buttons: buttons)
        }
        
        lastRowCount = rowCount - 1
        rowCount = 1
        cx = button.width + 4.f
        cy += button.height + 4.f
      } else {
        button.origin = CGPoint(x: cx, y: cy)
        cx += button.width + 4.f
        lastRowCount = rowCount
      }
      
      lastButton = button
    }
    
    if self.alignment == .right {
      let buttons = Array(self.buttons[totalCount-lastRowCount..<self.buttons.count])
      self.realignItemsToRight(buttons: buttons)
    }
  }
  
  private func realignItemsToRight(buttons: [ActionButton]) {
    let leftOverMargin =  UIScreen.main.bounds.width - 10 -
      (buttons.last?.origin.x ?? 0) - (buttons.last?.width ?? 0)
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
      
      if Constant.maxWidth < cx + size.width {
        cy += size.height + Metric.topBottomMargin * 2 + Metric.itemBetweenMargin
        cx = size.width + Metric.sideMargin * 2 + Metric.itemBetweenMargin
      } else {
        cx += size.width + Metric.sideMargin * 2 + Metric.itemBetweenMargin
      }
      
      if index == inputs.count - 1 {
        cy += size.height + Metric.topBottomMargin * 2
      }
    }
    
    return cy
  }
}

