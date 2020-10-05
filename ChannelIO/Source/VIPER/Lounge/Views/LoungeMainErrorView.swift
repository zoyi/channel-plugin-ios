//
//  LoungeMainErrorView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 07/05/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

//import RxCocoa
//import RxSwift

class LoungeMainErrorView: BaseView {
  let contentView = UIView().then {
    $0.backgroundColor = .white
  }
  let errorImageView = UIImageView().then {
    $0.contentMode = .center
    $0.image = CHAssets.getImage(named: "networkErrorIllust")
  }
  let descLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 14)
    $0.text = CHAssets.localized("ch.error.common.description")
    $0.textColor = CHColors.blueyGrey
  }
  let refreshButton = CHButtonFactory.errorRefresh()
  
  var refreshSignal = _RXRelay_PublishRelay<Any?>()
  var disposeBag = _RXSwift_DisposeBag()
  
  override func initialize() {
    super.initialize()
    
    self.backgroundColor = .white
    
    self.contentView.addSubview(self.errorImageView)
    self.contentView.addSubview(self.descLabel)
    self.contentView.addSubview(self.refreshButton)
    self.addSubview(self.contentView)
    
    self.refreshButton
      .signalForClick()
      .bind(to: self.refreshSignal)
      .disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.errorImageView.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
    }
    
    self.descLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.top.equalTo(self.errorImageView.snp.bottom).offset(20)
      make.centerX.equalToSuperview()
      make.leading.greaterThanOrEqualToSuperview().inset(20)
      make.trailing.lessThanOrEqualToSuperview().inset(20)
    }
    
    self.refreshButton.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.top.equalTo(self.descLabel.snp.bottom).offset(24)
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalTo(44)
      make.width.equalTo(44)
    }
    
    self.contentView.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
}
