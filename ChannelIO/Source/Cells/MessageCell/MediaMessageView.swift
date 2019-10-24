//
//  CHMImageView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 16/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import NVActivityIndicatorView
import SnapKit
import SDWebImage
import Photos

class MediaMessageView : BaseView {

  //MARK: properties
  let imageView = SDAnimatedImageView()
  let exportIcon = UIImageView().then {
    $0.image = CHAssets.getImage(named: "exportIcon")
    $0.isHidden = true
  }
  var placeholder: UIImage?
  
  static var imageMaxSize: CGSize = {
    let screenSize = UIScreen.main.bounds.size
    return CGSize(width: screenSize.width * 2 / 3, height: screenSize.height / 2)
  }()
  
  static var imageDefaultSize: CGSize = {
    let screenSize = UIScreen.main.bounds.size
    return CGSize(width: screenSize.width / 2, height: screenSize.height / 4)
  }()
  
  fileprivate var imageSize = imageDefaultSize

  var indicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 44, height: 44)).then {
    $0.type = .ballRotateChase
    $0.color = CHColors.light
    $0.startAnimating()
  }
  
  var progressView = TYProgressBar().then {
    $0.font = UIFont.systemFont(ofSize: 17)
    $0.textColor = .white
    $0.lineDashPattern = [2, 5]   // lineWidth, lineGap
    $0.lineHeight = 5
  }
  
  //MARK: methods
  
  override func initialize() {
    super.initialize()
    self.layer.cornerRadius = 6.f
    self.layer.borderWidth = 1.0
    self.layer.borderColor = CHColors.darkTwo.cgColor
    self.clipsToBounds = true
    
    self.addSubview(self.imageView)
    self.addSubview(self.exportIcon)
    self.addSubview(self.indicatorView)
    self.addSubview(self.progressView)
  }
  
  func configure(message: MessageCellModelType, isThumbnail: Bool) {
    guard let file = message.file else { return }
    guard file.image == true else { return }
    
    if message.isFailed {
      self.progressView.isHidden = true
      self.indicatorView.isHidden = true
    }
    
    self.exportIcon.isHidden = message.file?.imageRedirectUrl == nil

    if message.progress == 1 {
      self.progressView.isHidden = true
      self.indicatorView.isHidden = false
      self.indicatorView.startAnimating()
    }
    
    if let asset = file.asset, message.progress != 1.0 {
      self.indicatorView.isHidden = true
      self.progressView.isHidden = false
      
      asset.fetchImage(size: self.imageSize) { [weak self] (image, info) in
        self?.imageView.alpha = 0.4
        self?.imageView.image = image
        self?.placeholder = image
      }
      
      //change to delegation to update ui rather using redux
      self.progressView.progress = Double(message.progress)
      
    } else if let image = file.imageData, message.progress != 1.0 {
      self.indicatorView.isHidden = true
      self.progressView.isHidden = false
      self.imageView.alpha = 0.4
      self.imageView.image = image
      self.placeholder = image
      
      self.progressView.progress = Double(message.progress)
    } else {
      self.indicatorView.isHidden = false
      self.progressView.isHidden = true
      
      var urlString = isThumbnail ? file.previewThumb?.url ?? "" : file.url
      urlString = urlString == "" ? file.url : urlString
      let url = URL(string: urlString)
      
      if file.asset == nil {
        self.placeholder = nil
      }
      
      self.imageView.sd_setImage(with: url, completed: { [weak self] (image, error, cacheType, url) in
        self?.imageView.alpha = 1
        self?.indicatorView.stopAnimating()
      })
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.imageView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.exportIcon.snp.makeConstraints { (make) in
      make.trailing.equalToSuperview().inset(10)
      make.bottom.equalToSuperview().inset(10)
      make.height.equalTo(34)
      make.width.equalTo(34)
    }
    
    self.progressView.snp.remakeConstraints { (make) in
      make.width.equalTo(100)
      make.height.equalTo(100)
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
    }
    
    self.indicatorView.snp.remakeConstraints { (make) in
      make.width.equalTo(44)
      make.height.equalTo(44)
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
  
  func setProgress(value: CGFloat) {
    self.progressView.progress = Double(value)
  }

  class func getThumbnailImageSize(imageSize: CGSize) -> CGSize {
    let ratio = max(imageSize.width / imageMaxSize.width, imageSize.height / imageMaxSize.height)
    if ratio >= 1.0 {
      return CGSize(width: imageSize.width / ratio, height: imageSize.height / ratio)
    } else {
      return imageSize
    }
  }

  class func viewSize(fits width: CGFloat, viewModel: MessageCellModelType) -> CGSize {
    if let previewThumb = viewModel.file?.previewThumb {
      return getThumbnailImageSize(imageSize: CGSize(width: previewThumb.width, height: previewThumb.height))
    }
    
    var size = imageDefaultSize
    if let asset = viewModel.file?.asset {
      size = getThumbnailImageSize(imageSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight))
    } else if let image = viewModel.file?.imageData {
      size = getThumbnailImageSize(imageSize: image.size)
    }

    return size
  }
}
