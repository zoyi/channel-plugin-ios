//
//  MediaCollectionView.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/16.
//

import UIKit

class MediaCollectionView: BaseView {
  private struct Metrics {
    static let fileViewHeight = 70.f
    static let collectionMargin = 6.f
    static let mediaMinHeight = 56.f
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
      $0.minimumInteritemSpacing = 6
      $0.minimumLineSpacing = 6
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
    let flowLayout = self.collectionView.collectionViewLayout

    if let collectionViewLayout = flowLayout as? AlignedCollectionViewFlowLayout {
      collectionViewLayout.horizontalAlignment = horizontalAlignment
      self.collectionView.collectionViewLayout = collectionViewLayout
    }
  }

  static func viewHeight(fit width: CGFloat, models: [CHFile]) -> CGFloat {
    var height = 0.f
    let side = (width - Metrics.collectionMargin) / 2
    let imageCount = models.filter { $0.type == .image }.count
    if imageCount == 2 {
      height += side
    } else if imageCount > 2 {
      height += side * 2 + Metrics.collectionMargin
    }
    
    if imageCount > 1 && models.filter({ $0.type == .file }).count > 0 {
      height += Metrics.collectionMargin
    }
    
    for (index, file) in models.enumerated() {
      let margin = index == models.count - 1 ? 0 : Metrics.collectionMargin
      if file.type == .image && imageCount == 1 {
        height += max(file.thumbSize.height, Metrics.mediaMinHeight) + margin
      } else if file.type == .video {
        height += max(file.thumbSize.height, Metrics.mediaMinHeight) + margin
      } else if file.type == .file {
        height += Metrics.fileViewHeight + margin
      }
    }
    
    return height
  }
}

