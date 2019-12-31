//
//  FileCollectionViewCell.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/16.
//

class FileCollectionViewCell: BaseCollectionViewCell {
  private let fileView = FileView()

  override func initialize() {
    super.initialize()
    self.contentView.addSubview(self.fileView)
  }

  override func setLayouts() {
    super.setLayouts()

    self.fileView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func configure(with model: CHFile) {
    self.fileView.file = model
  }
}
