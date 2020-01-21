//
//  TextBlocksView.swift
//  ChannelIO
//
//  Created by intoxicated on 20/01/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Foundation

class TextBlocksView: BaseView {
  private struct Metrics {
    static let blockMargin = 5.f
  }

  private let tableView = ResizableTableView().then {
    $0.separatorStyle = .none
    $0.backgroundColor = .clear
    $0.allowsSelection = false
    $0.isScrollEnabled = false
    $0.register(cellType: TextBlockTableViewCell.self)
  }

  override func initialize() {
    super.initialize()
    self.backgroundColor = .clear
    self.addSubview(self.tableView)
  }

  override func setLayouts() {
    super.setLayouts()

    self.tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func setDataSource(_ source: (UITableViewDataSource & UITableViewDelegate), at row: Int) {
    self.tableView.dataSource = source
    self.tableView.delegate = source
    self.tableView.tag = row
    self.tableView.reloadData()
  }

  static func viewHeight(fit width: CGFloat, model: MessageCellModelType) -> CGFloat {
    var height = 0.f
    for block in model.blocks {
      height += TextBlockTableViewCell.cellHeight(fit: width, model: model, blockModel: block)
    }
    return height
  }
}
