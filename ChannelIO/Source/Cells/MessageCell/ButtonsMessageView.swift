//
//  ButtonsMessageView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 07/12/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

class ButtonsMessageView: BaseView {
  let containerView = UIView()
  var buttons: [UIButton] = []
  var redirectSignal = PublishSubject<String>()
  
  override func initialize() {
    super.initialize()
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.containerView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
  }
  
  func observeClickEvents() -> Observable<String> {
    return self.redirectSignal.asObservable()
  }
  
  func configure(model: MessageCellModelType) {
    self.prepareView(with: model)
    for (view, button) in zip(self.buttons, model.buttons) {
      view.setTitle(button.title, for: .normal)
      _ = view.signalForClick().subscribe(onNext: { [weak self] (_) in
        self?.redirectSignal.onNext(button.url)
      })
    }
  }
  
  func prepareView(with model: MessageCellModelType) {
    if self.buttons.count > model.buttons.count {
      for i in self.buttons.count-1...model.buttons.count {
        self.buttons[i].removeFromSuperview()
      }
      self.buttons = Array(self.buttons.dropLast(self.buttons.count-model.buttons.count))
    }
    else if self.buttons.count < model.buttons.count {
      for i in self.buttons.count..<model.buttons.count {
        let buttonView = UIButton(type: .system).then {
          $0.setTitleColor(CHColors.azure, for: .normal)
          $0.titleLabel?.numberOfLines = 1
        }
        self.containerView.addSubview(buttonView)
        buttonView.snp.makeConstraints { [weak self] (make) in
          let previous = i != 0 ? self?.buttons[i] : nil
          make.height.equalTo(44)
          make.leading.equalToSuperview()
          make.trailing.equalToSuperview()
          if i == 0 {
            make.top.equalToSuperview()
          } else {
            make.top.equalTo(previous!.snp.bottom)
          }
          
          if i == model.buttons.count - 1 {
            make.bottom.equalToSuperview()
          }
        }
      }
    }
  }
  
  class func viewHeight(fits width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
    return viewModel.buttons.reduce(0.f, { (sum, link) -> CGFloat in
      return sum + 44.f
    })
  }
}

//class ButtonView: BaseView {
//  let titleLabel = UILabel().then {
//    $0.textColor = CHColors.azure
//    $0.font = UIFont.systemFont(ofSize: 14)
//    $0.numberOfLines = 1
//  }
//
//  override func initialize() {
//    super.initialize()
//    self.layer.borderWidth = 3.f
//    self.layer.borderColor = CHColors.paleGrey.cgColor
//    self.layer.cornerRadius = 12.f
//    self.backgroundColor = .white
//
//    self.addSubview(self.titleLabel)
//  }
//
//  override func setLayouts() {
//    super.setLayouts()
//
//    self.titleLabel.snp.makeConstraints { (make) in
//      make.centerX.equalToSuperview()
//      make.leading.equalToSuperview().inset(20)
//      make.trailing.equalToSuperview().inset(20)
//    }
//  }
//
//  func configure(title: String) {
//    self.titleLabel.text = title
//  }
//}
