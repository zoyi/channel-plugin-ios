//
//  UserInfoGuideView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 16/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit

enum DialogType {
  case UserName
  case PhoneNumber
  case Completed
  case Default
  case None
}

class DialogView : BaseView {
  //MARK: Constant
  
  struct Constant {
    static let titleViewCornerRadius = 3.f
  }
  
  struct Metric {
    static let titleSideMargin = 6.f
    static let titleTopDownMargin = 3.f
    static let titleViewTopMargin = 14.f
    static let messageTopMargin = 7.f
    static let messageSideMargin = 20.f
    static let footerSideMargin = 32.f
    static let footerTopMargin = 10.f
    static let footerBottomMargin = 14.f
    static let dividerHeight = 1.f
    static let actionViewHeight = 56.f
  }
  
  struct Font {
    static let titleLabel = UIFont.boldSystemFont(ofSize: 13)
    static let messageLabel = UIFont.systemFont(ofSize: 16)
    static let footerLabel = UIFont.systemFont(ofSize: 11)
  }
  
  struct Color {
    static let titleView = UIColor.white
    static let titleLabel = CHColors.blueyGrey
    static let messageLabel = CHColors.dark
    static let footerLabel = CHColors.blueyGrey
    static let titleLabelCompleted = CHColors.shamrockGreen
  }
  
  //MARK: properties
  let dialogView = UIView()
  
  let titleView = UIView().then {
    $0.layer.cornerRadius = Constant.titleViewCornerRadius
    $0.backgroundColor = UIColor.clear
  }
  
  let titleLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = Font.titleLabel
    $0.textColor = Color.titleLabel
    $0.textAlignment = .center
  }
  
  let messageLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = Font.messageLabel
    $0.textColor = CHColors.dark
    $0.textAlignment = .center
  }
  
  let footerLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = Font.footerLabel
    $0.textColor = Color.footerLabel
    $0.textAlignment = .center
    $0.isHidden = true
  }
  
  let divider = UIView().then {
    $0.backgroundColor = CHColors.lightGray
  }
  
  var nameFieldView = TextActionView().then {
    $0.isHidden = true
  }
  var phoneFieldView = PhoneActionView().then {
    $0.isHidden = true
  }
  
  var viewModel: DialogViewModelType?
  var hasError = false
  var type: DialogType = .UserName
  var returnSubject = PublishSubject<Any?>()
  var countryCodeSubject = PublishSubject<String>()
  let disposeBeg = DisposeBag()
  
  override func initialize() {
    super.initialize()
    self.translatesAutoresizingMaskIntoConstraints = false
    
    self.layer.cornerRadius = 6
    self.layer.shadowColor = CHColors.dark.cgColor
    self.layer.shadowOpacity = 0.2
    self.layer.shadowOffset = CGSize(width: 0, height: 2)
    self.layer.shadowRadius = 3
    self.layer.borderWidth = 1
    self.layer.borderColor = CHColors.lightGray.cgColor
    self.backgroundColor = CHColors.white
    
    self.addSubview(self.dialogView)
    self.addSubview(self.divider)
    self.addSubview(self.nameFieldView)
    self.addSubview(self.phoneFieldView)
    
    self.titleView.addSubview(self.titleLabel)
    self.dialogView.addSubview(self.titleView)
    self.dialogView.addSubview(self.messageLabel)
    self.dialogView.addSubview(self.footerLabel)
  }
  
  func configure(viewModel: DialogViewModelType) {
    self.viewModel = viewModel
    
    self.titleLabel.text = viewModel.title
    self.messageLabel.text = viewModel.message
    if viewModel.shouldShowFooter() {
      //self.footerLabel.text = self.viewModel?.footer
      _ = self.footerLabel.signalForClick()
        .subscribe(onNext: { [weak self] _ in
        self?.openAgreement()
      })
      
      //TODO: better way to find a html tag to attributedString...
      let attrString = NSMutableAttributedString(string: viewModel.footer)
      let range = NSRange(location: 0, length: viewModel.footer.count)
      attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: Color.footerLabel, range: range)
      attrString.addAttribute(NSAttributedStringKey.font, value: Font.footerLabel, range: range)
      let boldRange = (attrString.string as NSString).range(of: CHAssets.localized("ch.terms_of_service").lowercased())
      attrString.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 11), range: boldRange)
      let paragraph = NSMutableParagraphStyle()
      paragraph.alignment = .center
      attrString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraph, range: range)
      self.footerLabel.attributedText = attrString
    }
    
    self.setGuideType(type: viewModel.type)
    
    self.setNeedsLayout()
    self.layoutIfNeeded()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.titleLabel.snp.remakeConstraints { [weak self] (make) in
      if self?.titleLabel.text == "" {
        make.height.equalTo(0)
      } else {
        make.leading.equalToSuperview().inset(Metric.titleSideMargin)
        make.trailing.equalToSuperview().inset(Metric.titleSideMargin)
        make.top.equalToSuperview().inset(Metric.titleTopDownMargin)
        make.bottom.equalToSuperview().inset(Metric.titleTopDownMargin)
      }
    }
    
    self.titleView.snp.remakeConstraints { [weak self] (make) in
      if self?.titleLabel.text == "" {
        make.height.equalTo(0)
        make.top.equalToSuperview()
      } else {
        make.centerX.equalToSuperview()
        make.top.equalToSuperview().inset(Metric.titleViewTopMargin)
        make.height.equalTo(24).priority(1000)
      }
    }
    
    self.messageLabel.snp.remakeConstraints { [weak self] (make) in
      if self?.messageLabel.text == "" ||
        self?.messageLabel.isHidden == true {
        make.height.equalTo(0)
        make.top.equalTo((self?.titleView.snp.bottom)!)
      } else {
        make.top.equalTo((self?.titleView.snp.bottom)!).offset(Metric.messageTopMargin)
        make.leading.equalToSuperview().inset(Metric.messageSideMargin)
        make.trailing.equalToSuperview().inset(Metric.messageSideMargin)
      }
    }
    
    self.footerLabel.snp.remakeConstraints { [weak self] (make) in
      if self?.footerLabel.text == "" ||
        self?.footerLabel.isHidden == true {
        make.height.equalTo(0)
        make.top.equalTo((self?.messageLabel.snp.bottom)!)
        make.leading.equalToSuperview()
        make.trailing.equalToSuperview()
      } else {
        make.top.equalTo((self?.messageLabel.snp.bottom)!).offset(Metric.footerTopMargin)
        make.leading.equalToSuperview().inset(Metric.footerSideMargin)
        make.trailing.equalToSuperview().inset(Metric.footerSideMargin)
      }
      //make.bottom.equalToSuperview().inset(Metric.footerBottomMargin)
    }
    
    self.dialogView.snp.remakeConstraints { [weak self] (make) in
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      
      if self?.type == .Completed {
        make.bottom.equalToSuperview()
      }
    }
    
    self.divider.snp.remakeConstraints { [weak self] (make) in
      make.height.equalTo(self?.type == .Completed ? 0 : Metric.dividerHeight)
      make.top.equalTo((self?.dialogView.snp.bottom)!)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    
    let actionView = !self.nameFieldView.isHidden ?
      self.nameFieldView : self.phoneFieldView
    
    if self.type == .Completed {
      self.nameFieldView.isHidden = true
      self.phoneFieldView.isHidden = true
    } else {
      actionView.snp.remakeConstraints({ [weak self] (make) in
        make.height.equalTo(Metric.actionViewHeight)
        make.top.equalTo((self?.divider.snp.bottom)!)
        make.leading.equalToSuperview()
        make.trailing.equalToSuperview()
        make.bottom.equalToSuperview()
      })
    }
  }
  
  class func viewHeight(fits width:CGFloat, viewModel: DialogViewModelType) -> CGFloat {
    var height:CGFloat = 0.0
    
    if viewModel.title != "" {
      height += 15 //top
      height += viewModel.title.height(
        fits: width - Metric.messageSideMargin * 2,
        font: Font.titleLabel)
      height += 6
    }
    
    if viewModel.message != "" {
      height += 10 //top
      height += viewModel.message.height(
        fits: width - Metric.messageSideMargin * 2,
        font: Font.messageLabel)
    }
    
    if viewModel.footer != "" && viewModel.shouldShowFooter() {
      height += 8 //top
      height += viewModel.footer.height(
        fits: width - Metric.messageSideMargin * 2,
        font: Font.footerLabel)
    }
    
    height += 14 //outer bot margin
    
    if viewModel.type != .Completed &&
      viewModel.type != .Default {
      height += 1 //divider
      height += 56 //action view
    }
    
    return height
  }
  
  // MARK: Signal
  
  func signalForSuccess() -> PublishSubject<Any?> {
    return self.returnSubject
  }
  
  func signalForCountryCode() -> PublishSubject<String> {
    return self.countryCodeSubject
  }
  // MARK: helpers
  func setGuideType(type: DialogType) {
    self.type = type
    
    switch type {
    case .UserName:
      self.handleNameAction()
      break
    case .PhoneNumber:
      self.handlePhoneAction()
      break
    case .Completed:
      self.titleLabel.textColor = Color.titleLabelCompleted
      self.titleView.backgroundColor = Color.titleView
      self.messageLabel.isHidden = true
      self.footerLabel.isHidden = true
      break
    default:
      break
    }
  }
}

extension DialogView {
  func handleError() {
    self.titleView.backgroundColor = CHColors.yellowishOrange
    self.titleLabel.text = self.viewModel?.errorTitle
    self.titleLabel.textColor = CHColors.white
    self.messageLabel.text = self.viewModel?.errorMessage
    
    let animation = CABasicAnimation(keyPath: "position")
    animation.duration = 0.07
    animation.repeatCount = 4
    animation.autoreverses = true
    animation.fromValue =  NSValue(cgPoint: CGPoint(x:self.center.x - 10, y:self.center.y))
    animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y:self.center.y))
    self.layer.add(animation, forKey: "position")
  }
}
//MARK: Name action

extension DialogView {
  func handleNameAction() {
    self.nameFieldView.isHidden = false
    self.phoneFieldView.isHidden = true
    self.footerLabel.isHidden = false
    
    var user = mainStore.state.guest
    self.nameFieldView.signalForAction()
      .flatMap({ (name) -> Observable<(CHGuest?, Any?)> in
        user.name = name as! String
        return user.update()
      })
      .subscribe(onNext: { [weak self] (guest, error) in
        //dispatch action
        if error != nil {
          self?.handleError()
          return
        }

        mainStore.dispatch(UpdateGuest(payload: guest!))
        
        guard user.mobileNumber != nil else {
          mainStore.dispatch(UpdateUserInfoGuide(payload: .PhoneNumber))
          return
        }

        mainStore.dispatch(CompleteUserInfoGuide())
      }).disposed(by: self.disposeBeg)
  }
}

//MARK: Phone action

extension DialogView {
  func handlePhoneAction() {
    self.nameFieldView.isHidden = true
    self.phoneFieldView.isHidden = false
    self.footerLabel.isHidden = false
    
    var user = mainStore.state.guest
    
    self.phoneFieldView.countryCodeView.signalForClick()
      .subscribe(onNext: { [weak self] (event) in
        var code = self?.phoneFieldView.countryLabel.text ?? ""
        if code != "" {
          code.remove(at: code.startIndex)
        }
        self?.countryCodeSubject.onNext(code)
      }).disposed(by: self.disposeBeg)
    
    self.phoneFieldView.signalForAction()
      .flatMap({ (number) -> Observable<(CHGuest?, Any?)> in
        user.mobileNumber = number as! String?
        return user.update()
      })
      .subscribe(onNext: { [weak self] (guest, error) in
        if error != nil {
          self?.handleError()
          return
        }

        mainStore.dispatch(UpdateGuest(payload: guest!))
        mainStore.dispatch(CompleteUserInfoGuide())
      }).disposed(by: self.disposeBeg)
  }
  
  func setCountryCodeText(code: String) {
    self.phoneFieldView.countryLabel.text = "+" + code
  }
  
  func openAgreement() {
    let locale = CHUtils.getLocale() ?? .korean
    let url = "https://channel.io/" +
        locale.rawValue +
        "/terms_user?channel=" +
        (mainStore.state.channel.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")
    
    guard let link = URL(string: url) else { return }
    link.open()
  }
}

