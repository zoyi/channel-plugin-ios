//
//  CHBooleanField.swift
//  ChannelIO
//
//  Created by 김진학 on 2020/07/22.
//  Copyright © 2020 ZOYI. All rights reserved.
//

//import RxSwift
//import RxCocoa

final class CHBooleanField: BaseView {
  private enum Metrics {
    static let fieldHeight = 52.f
    static let dividerHeight = 0.5.f
  }

  private let topDivider = UIView().then {
    $0.backgroundColor = UIColor.grey300
  }

  private let botDivider = UIView().then {
    $0.backgroundColor = UIColor.grey300
  }

  private let tableView = UITableView().then {
    $0.separatorStyle = .none
    $0.isScrollEnabled = false
    $0.register(cellType: CHBooleanSelectCell.self)
  }

  private let validSubject = _RXRelay_PublishRelay<Bool>()
  private let changeSubject = _RXRelay_PublishRelay<String>()
  
  private var selectedPosition: Int = 2

  convenience init(bool: Bool?) {
    self.init(frame: CGRect.zero)
    self.setText(
      bool == true
        ? "true" : bool == false
        ? "false" : ""
    )
  }

  override func initialize() {
    super.initialize()

    self.tableView.delegate = self
    self.tableView.dataSource = self

    self.backgroundColor = UIColor.white

    self.addSubview(self.topDivider)
    self.addSubview(self.tableView)
    self.addSubview(self.botDivider)
  }

  override func setLayouts() {
    super.setLayouts()

    self.topDivider.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.height.equalTo(Metrics.dividerHeight)
    }

    self.botDivider.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview().inset(Metrics.dividerHeight)
      make.height.equalTo(Metrics.dividerHeight)
    }

    self.tableView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.bottom.equalToSuperview().inset(Metrics.dividerHeight)
    }
  }
}

extension CHBooleanField: CHFieldDelegate {
  func getText() -> String {
    switch selectedPosition {
    case 0: return "true"
    case 1: return "false"
    default: return ""
    }
  }

  func setText(_ value: String) {
    switch value.lowercased() {
    case "true":
      self.selectedPosition = 0
    case "false":
      self.selectedPosition = 1
    default:
      self.selectedPosition = 2
    }
  }
  
  func isValid() -> _RXSwift_Observable<Bool> {
    return self.validSubject.asObservable()
  }
  
  func hasChanged() -> _RXSwift_Observable<String> {
    return self.changeSubject.asObservable()
  }
}

extension CHBooleanField: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return Metrics.fieldHeight
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: CHBooleanSelectCell = tableView.dequeueReusableCell(for: indexPath)
    let isSelected = self.selectedPosition == indexPath.row
    switch indexPath.row {
    case 0:
      cell.configure(
        text: CHAssets.localized("ch.profile_form.boolean.yes"),
        isSelect: isSelected
      )
    case 1:
      cell.configure(
        text: CHAssets.localized("ch.profile_form.boolean.no"),
        isSelect: isSelected
      )
    case 2:
      cell.configure(
        text: CHAssets.localized("ch.profile_form.boolean.none"),
        isSelect: isSelected
      )
    default: break
    }

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.selectedPosition = indexPath.row
    tableView.reloadData()
    tableView.deselectRow(at: indexPath, animated: false)
    self.validSubject.accept(true)
    self.changeSubject.accept(self.getText())
  }
}
