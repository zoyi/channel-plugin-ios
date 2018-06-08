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

class ActionButton: UIButton {
  var value: CHi18n? = nil
  var key: String = ""
  
  required init(input: CHInput) {
    super.init(frame: CGRect.zero)
    self.value = input.value
    self.key = input.key
    
    self.titleLabel?.numberOfLines = 2
    self.titleEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    self.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    self.setTitle(self.value?.getMessage() ?? "", for: .normal)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class ActionablesView: UIControl {
  var actionButtons: [ActionButton] = []
  var maxActionWidth = 300.f
  var selectedMessageLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 15)
    $0.isHidden = false
  }
  
  var leftMargin: CGFloat = 10.f
  var rightMargin: CGFloat = 10.f
  
  var actionSignal = PublishSubject<ActionKey>()
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setup()
  }
  
  func setup() {
    //do some setups
    self.addSubview(self.selectedMessageLabel)
    
    self.selectedMessageLabel.snp.makeConstraints { (make) in
      make.leading.greaterThanOrEqualToSuperview().inset(65)
      make.trailing.equalToSuperview().inset(10)
      make.top.equalToSuperview().inset(5)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.invalidateIntrinsicContentSize()
    
    var totalRect:CGRect = CGRect.zero
    var enumerator = self.actionButtons.enumerated().makeIterator()
    self.enumerateItemRectsUsing { (itemRect) in
      let (_, action) = enumerator.next()!
      action.frame = itemRect
      totalRect = totalRect.union(itemRect)
    }
  }
  
  private func enumerateItemRectsUsing(block: (_ itemRect: CGRect) -> ()) {
    var rowCount = 0
    var x = self.leftMargin, y = 10.f
    let margin = 10.f
    let lineHeight = 34.f
    
    for button in self.actionButtons {
      let width = max(self.bounds.width, button.frame.width)
      let buttonWidth = min(self.maxActionWidth, button.frame.width)
      
      if x > width - buttonWidth - self.rightMargin {
        y += lineHeight + margin
        x = self.leftMargin
        rowCount = 0
      }
      
      block(CGRect(x: x, y: y, width: buttonWidth, height: button.frame.height))
      x += buttonWidth + margin
      rowCount = rowCount + 1
    }
  }
  
  func configure(viewModel: MessageCellModelType) {
    guard let form = viewModel.message.form else { return }
    
    for view in self.subviews {
      if !(view is UILabel) {
        view.removeFromSuperview()
      }
    }
    
    guard !viewModel.shouldDisplaySelectedAction else {
      self.selectedMessageLabel.isHidden = false
      self.selectedMessageLabel.text = viewModel.selectedActionText
      return
    }
    
    let inputs = form.inputs
    self.actionButtons.removeAll()
    
    for (index, input) in inputs.enumerated() {
      let button = ActionButton(input: input)
      button.autoresizingMask = UIViewAutoresizing.init(rawValue: 0)
      button.tag = index
      
      self.actionButtons.append(button)
      self.addSubview(button)
      _ = button.signalForClick().subscribe(onNext: { [weak self] _ in
        self?.actionSignal.onNext(input.key)
      })
    }
  }
  
  func observeAction() -> Observable<ActionKey> {
    return self.actionSignal.asObserver()
  }
}

class ActionableMessageView: BaseView {
  var actionView = ActionablesView()
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.actionView)
  }
  
  override func setLayouts() {
    super.setLayouts()
  }
  
  func configure(viewModel: MessageCellModelType) {
    self.actionView.configure(viewModel: viewModel)
  }
  
  static func viewHeight(fit width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
    var rowCount = 0
    var x = 10.f, y = 10.f
    let margin = 10.f
    let lineHeight = 34.f
    let inputs = viewModel.message.form?.inputs ?? []
    
    for input in inputs {
      let width = input.value?.getMessage()?.width(with: UIFont.systemFont(ofSize: 15), maximumNumberOfLines: 2) ?? 0.f
      let buttonWidth = min(300.f, width)
      
      if x > width - buttonWidth - 10.f {
        y += lineHeight + margin
        x = 10.f
        rowCount = 0
      }
      
      x += buttonWidth + margin
      rowCount = rowCount + 1
    }
    return CGFloat(rowCount * 34)
  }
}
