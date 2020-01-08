//
//  MediaCollectionView.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/16.
//

import UIKit

class MediaCollectionView: BaseView {
  private struct Constants {
    static let MediaMessageCellSide = 115.f
  }
  var collectionView: UICollectionView!

  override func initialize() {
    super.initialize()
    self.initCollectionView()
  }

  override func setLayouts() {
    super.setLayouts()

    self.collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func initCollectionView() {
    let flowLayout = AlignedCollectionViewFlowLayout(
      horizontalAlignment: .left,
      verticalAlignment: .center
    ).then {
      $0.scrollDirection = .vertical
      $0.minimumInteritemSpacing = 8
      $0.minimumLineSpacing = 8
    }
    self.collectionView = UICollectionView(
      frame: CGRect.zero, collectionViewLayout: flowLayout
    )
    
    self.collectionView.backgroundColor = .clear
    self.collectionView.isScrollEnabled = false
    self.collectionView.register(cellType: MediaCollectionViewCell.self)
    self.collectionView.register(cellType: FileCollectionViewCell.self)
    self.addSubview(self.collectionView)
  }

  func setDataSource(_ source: UICollectionViewDataSource & UICollectionViewDelegateFlowLayout, at row: Int) {
    self.collectionView.dataSource = source
    self.collectionView.delegate = source
    self.collectionView.tag = row
    self.collectionView.reloadData()
  }

  func configure(models: [CHFile]) {}
  
  func changeFlowLayout(horizontalAlignment: HorizontalAlignment) {
    let flowLayout = AlignedCollectionViewFlowLayout(
      horizontalAlignment: horizontalAlignment,
      verticalAlignment: .center
    ).then {
      $0.scrollDirection = .vertical
      $0.minimumInteritemSpacing = 8
      $0.minimumLineSpacing = 8
    }
    self.collectionView.collectionViewLayout = flowLayout
  }

  static func viewHeight(fit width: CGFloat, models: [CHFile]) -> CGFloat {
    var height = 0.f
    // TODO: change to controller view width
    let side = (width - Constants.MediaMessageCellSide - 8) / 2
    let imageCount = models.filter { $0.type == .image }.count
    if imageCount == 2 {
      height += side + 8
    } else if imageCount > 2 {
      height += side + side + 8
    }
    models.forEach { (file) in
      if file.type == .image {
        if imageCount == 1 {
          height += file.thumbSize.height + 8
        }
      } else if file.type == .video {
         height += file.thumbSize.height + 8
      } else if file.type == .file {
        height += 70 + 8
      }
    }
    return height
  }
}

