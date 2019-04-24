//
//  SettingView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

class SettingView: BaseViewController {
  var presenter: SettingPresenterProtocol?
  
  let headerView = SettingHeaderView()
  let tableView = UITableView().then {
    $0.register(cellType: LabelCell.self)
    $0.register(cellType: SwitchCell.self)
    $0.register(cellType: KeyValueCell.self)
    
    $0.separatorStyle = .none
    $0.estimatedRowHeight = 0
    $0.sectionFooterHeight = 0
    $0.sectionHeaderHeight = 0
  }
  let versionLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 10)
    $0.textColor = CHColors.blueyGrey
  }
  
  struct Section {
    static let options = 0
    static let profiles = 1
  }

  var options: [SettingOptionModel] = []
  var profiles: [GuestProfileItemModel] = []
  
  var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.addSubview(self.headerView)
    self.view.addSubview(self.tableView)
    
    presenter?.viewDidLoad()
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    self.headerView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.height.equalTo(86)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      if #available(iOS 11.0, *) {
        make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
      } else {
        make.top.equalToSuperview()
      }
    }
    
    self.tableView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.top.equalTo(self.headerView.snp.bottom)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      if #available(iOS 11.0, *) {
        make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(38)
      } else {
        make.bottom.equalToSuperview().inset(38)
      }
    }
    
    self.versionLabel.snp.makeConstraints { (make) in
      make.bottom.equalToSuperview()
      make.trailing.equalToSuperview()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.presenter?.prepare()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.presenter?.cleanup()
  }
}

extension SettingView: SettingViewProtocol {
  func displayHeader(with model: SettingHeaderViewModel) {
    self.headerView.configure(with: model)
  }
  
  func displayOptions(with options: [SettingOptionModel]) {
    self.options = options
    self.tableView.reloadData()
  }
  
  func displayProfiles(with profiles: [GuestProfileItemModel]) {
    self.profiles = profiles
    self.tableView.reloadData()
  }
  
  func displayVersion(version: String) {
    self.versionLabel.text = version
  }
}

extension SettingView: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case Section.options:
      return self.options.count
    case Section.profiles:
      return self.profiles.count
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
    case Section.options:
      return self.options.count != 0 ? 38.f : CGFloat.leastNormalMagnitude
    case Section.profiles:
      return self.profiles.count != 0 ? 38.f : CGFloat.leastNormalMagnitude
    default:
      return CGFloat.leastNormalMagnitude
    }
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch section {
    case Section.options:
      return UIView()
    case Section.profiles:
      return UIView()
    default:
      return nil
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 48.f
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch (indexPath.section, indexPath.row) {
    case (Section.options, _):
      let item = self.options[indexPath.row]
      switch item.option {
      case .none:
        let cell: LabelCell = tableView.dequeueReusableCell(for: indexPath)
        cell.arrowImageView.isHidden = false
        cell.isUserInteractionEnabled = false
        cell.titleLabel.text = item.title
        return cell
      case .selectable, .editable:
        let cell: LabelCell = tableView.dequeueReusableCell(for: indexPath)
        cell.arrowImageView.isHidden = true
        cell.signalForClick().subscribe(onNext: { [weak self] (_) in
          self?.presenter?.didClickOnOption(item: item, nextValue: nil, from: self)
        }).disposed(by: self.disposeBag)
        cell.titleLabel.text = item.title
        return cell
      case .switchable:
        let cell: SwitchCell = tableView.dequeueReusableCell(for: indexPath)
        let isOn = item.value as? Bool ?? false
        cell.switchSignal.subscribe { [weak self] event in
          self?.presenter?.didClickOnOption(item: item, nextValue: event.element, from: self)
        }.disposed(by: self.disposeBag)
        cell.selectionStyle = .none
        cell.configure(title: item.title, isOn: isOn)
        return cell
      }

    case (Section.profiles, _):
      let profile = self.profiles[indexPath.row]
      let cell: KeyValueCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(title: profile.profileName, detail: profile.profileValue as? String)
      cell.signalForClick().subscribe(onNext: { [weak self] _ in
        self?.presenter?.didClickOnProfileSchema(with: profile, from: self)
      }).disposed(by: self.disposeBag)
      return cell
    default:
      return  UITableViewCell()
    }
  }
}