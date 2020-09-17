//
//  AlertViewController.swift
//  ChannelIO
//
//  Created by Jam on 2020/03/05.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

enum AlertType {
  case normal
  case persist
  case check(value: Bool)
  case actionSheet
  case completion
}

struct AlertAction {
  var title = ""
  var type: AlertActionType = .normal
  var handler: ((Bool) -> Void)?
}

struct AlertTextContext {
  var title: String?
  var titleColor: UIColor?
  var attributedTitle: NSAttributedString?

  var desc: String?
  var descColor: UIColor?
  var attributedDesc: NSAttributedString?

  var mainText: String?
  var mainTextColor: UIColor?
  var attributedMainText: NSAttributedString?

  init(title: String? = nil, titleColor: UIColor? = nil, attributedTitle: NSAttributedString? = nil,
       desc: String? = nil, descColor: UIColor? = nil, attributedDesc: NSAttributedString? = nil,
       mainText: String? = nil, mainTextColor: UIColor? = nil, attributedMainText: NSAttributedString? = nil) {
    self.title = title
    self.titleColor = titleColor
    self.attributedTitle = attributedTitle

    self.desc = desc
    self.descColor = descColor
    self.attributedDesc = attributedDesc

    self.mainText = mainText
    self.mainTextColor = mainTextColor
    self.attributedMainText = attributedMainText
  }
}

protocol AlertViewProtocol { }

class AlertViewController: BaseViewController {
  let alertView = AlertView().then {
    $0.alpha = 0
  }

  let completionView = AlertCompletionView()

  let dimView = UIView().then {
    $0.backgroundColor = .black
    $0.alpha = 0.4
  }

  var type: AlertType = .normal
  var bottomConstraint: Constraint?
  var animated = false
  
  let disposeBag = DisposeBag()

  init(message: String, imageName: String) {
    super.init()

    self.modalTransitionStyle = .crossDissolve
    self.modalPresentationStyle = .overCurrentContext

    self.type = .completion

    self.alertView.isHidden = true
    self.completionView.isHidden = false
    self.dimView.backgroundColor = .clear
    self.completionView.configure(title: message, imageName: imageName)
  }

  init(context: AlertTextContext, type: AlertType) {
    super.init()

    self.modalTransitionStyle = .crossDissolve
    self.modalPresentationStyle = .overCurrentContext

    self.type = type

    self.alertView.isHidden = false
    self.completionView.isHidden = true

    if let title = context.title {
      self.alertView.addTitle(text: title, textColor: context.titleColor)
    } else if let attrTitle = context.attributedTitle {
      self.alertView.addAttributedTitle(text: attrTitle)
    }

    if let desc = context.desc {
      self.alertView.addDescription(text: desc)
    } else if let attrDesc = context.attributedDesc {
      self.alertView.addDescription(attributedText: attrDesc)
    }

    self.alertView.addMainSection(type: type, text: context.mainText ?? "")
  }

  init(title: String?, desc: String? = nil, message: String? = nil, attrMessage: NSAttributedString? = nil, type: AlertType) {
    super.init()

    self.modalTransitionStyle = .crossDissolve
    self.modalPresentationStyle = .overCurrentContext

    self.type = type

    self.alertView.isHidden = false
    self.completionView.isHidden = true

    self.alertView.addTitle(text: title)
    self.alertView.addDescription(text: desc)
    self.alertView.addMainSection(type: type, text: message, attrText: attrMessage)
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = UIColor.clear
    self.view.addSubview(self.dimView)
    self.view.addSubview(self.alertView)
    self.view.addSubview(self.completionView)

    _ = self.dimView.signalForClick().subscribe { [weak self] _ in
      guard let type = self?.type else { return }
      switch type {
      case .persist:
        break
      default:
        self?.dismiss(animated: true, completion: nil)
      }
    }

    self.setLayouts()

    switch self.type {
    case .completion:
      Observable<Int>.timer(.seconds(1), scheduler: MainScheduler.instance)
        .subscribe(onNext: { [weak self] _ in
        self?.dismiss(animated: true, completion: nil)
      }).disposed(by: self.disposeBag)
    default:
      break
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.dismiss(animated: false, completion: nil)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if self.viewIfLoaded?.window != nil && !self.animated && self.alertView.frame.height != 0 {
      self.animated = true

      switch self.type {
      case .actionSheet:
        self.bottomConstraint?.update(offset: -10)
        self.alertView.alpha = 1
        UIView.animate(withDuration: 0.30, delay: 0.0, options: .curveLinear, animations: {
          self.view.layoutIfNeeded()
        }, completion: nil)
      default:
        UIView.animate(withDuration: 0.5, animations: {
          self.alertView.alpha = 1
        })
      }
    }
  }

  func setLayouts() {
    self.alertView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()

      switch self.type {
      case .actionSheet:
        make.width.equalTo(UIScreen.main.bounds.width - 20)
        if #available(iOS 11.0, *) {
          self.bottomConstraint = make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(400).constraint
        } else {
          self.bottomConstraint = make.bottom.equalToSuperview().offset(400).constraint
        }
      default:
        make.centerY.equalToSuperview()
        make.width.equalTo(UIScreen.main.bounds.width - 80)
      }
    }

    self.completionView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.centerX.equalToSuperview()
      make.leading.greaterThanOrEqualToSuperview().inset(20)
      make.trailing.lessThanOrEqualToSuperview().inset(20)
    }

    self.dimView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  public func addAction(_ actionModel: AlertAction) {
    self.alertView.addAction(
      actionTitle: actionModel.title,
      type: actionModel.type,
      handler: { [weak self] checked in
        self?.dimissController(checked, actionModel: actionModel)
      })
  }

  fileprivate func dimissController(_ checked: Bool, actionModel: AlertAction) {
    switch self.type {
    case .actionSheet:
      self.bottomConstraint?.update(offset: self.alertView.frame.height)
      UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveLinear, animations: { [weak self] in
        self?.view.layoutIfNeeded()
      }, completion: { [weak self] _ in
        self?.dismiss(animated: true, completion: {
          actionModel.handler?(checked)
        })
      })
    default:
      self.dismiss(animated: true, completion: {
        actionModel.handler?(checked)
      })
    }
  }
}
