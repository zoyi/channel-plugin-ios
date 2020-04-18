//
//  LanguageOptionViewController.swift
//  ChannelIO
//
//  Created by Haeun Chung on 09/04/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit
import SnapKit
import Reusable
import RxSwift
import JGProgressHUD

class LanguageOptionViewController: BaseViewController {
  private let tableView = UITableView(frame: CGRect.zero, style: .grouped).then {
    $0.separatorStyle = .none
  }
  
  let locales = [
    CHLocaleString.korean,
    CHLocaleString.english,
    CHLocaleString.japanese
  ]
  
  let currentLocale: CHLocaleString? = CHUtils.getLocale()
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.initNavigation()
    self.initTableView()
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.tableView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
  }
  
  func initTableView() {
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.sectionHeaderHeight = 30
    self.tableView.backgroundColor = .white
    self.tableView.register(cellType: CheckableLabelCell.self)
    self.view.addSubview(self.tableView)
  }
  
  func initNavigation() {
    let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    spacer.width = -8
    
    let backButton = NavigationItem(
      image:  CHAssets.getImage(named: "back"),
      tintColor: mainStore.state.plugin.textUIColor,
      style: .plain,
      actionHandler: { [weak self] in
        _ = self?.navigationController?.popViewController(animated: true)
      })
    
    if #available(iOS 11, *) {
      self.navigationItem.leftBarButtonItems = [backButton]
    } else {
      self.navigationItem.leftBarButtonItems = [spacer, backButton]
    }
    
    let titleView = SimpleNavigationTitleView()
    titleView.configure(
      with: CHAssets.localized("ch.user_profile.locale.label"),
      textColor: mainStore.state.plugin.textUIColor
    )
    self.navigationItem.titleView = titleView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.dropShadow()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.removeShadow()
  }
}

extension LanguageOptionViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.locales.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: CheckableLabelCell = tableView.dequeueReusableCell(for: indexPath)
    let locale = self.locales[indexPath.row]
    cell.checked = self.currentLocale == locale
    
    if locale == .korean {
      cell.titleLabel.text = CHAssets.localized("ko")
    } else if locale == .english {
      cell.titleLabel.text = CHAssets.localized("en")
    } else if locale == .japanese {
      cell.titleLabel.text = CHAssets.localized("ja")
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 52
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.5
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.addBorders(edges: .bottom, color: CHColors.darkTwo, thickness: 0.5)
    return view
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView().then {
      $0.backgroundColor = CHColors.darkTwo
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let locale = self.locales[indexPath.row]
    ChannelIO.settings?.language = CHUtils.stringToLocale(locale.rawValue)
    
    let hud = JGProgressHUD(style: .dark)
    hud.show(in: self.view)
    
    CHUser
      .updateLanguage(with: locale.rawValue)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (user, error) in
        defer { hud.dismiss() }
        
        mainStore.dispatch(UpdateUser(payload: user))
        
        guard let error = error else {
          tableView.deselectRow(at: indexPath, animated: true)
          _ = self?.navigationController?.popViewController(animated: true)
          return
        }
        
        CustomFloatingBanner(
          title: error.errorDescription ?? error.localizedDescription,
          style: .warning
        ).show()
      }, onError: { (error) in
        hud.dismiss()
      }).disposed(by: self.disposeBag)
  }
}
