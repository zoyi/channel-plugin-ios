//
//  PlayDurationView.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/16.
//

import UIKit

struct PlayDurationModel {
  var font: UIFont
  var textColor: UIColor
  var backgroundColor: UIColor?
  var topColor: UIColor?
  var bottomColor: UIColor?
  var durationText: String

  init(
    duration: Double,
    font: UIFont = UIFont.systemFont(ofSize: 14),
    textColor: UIColor = .white,
    backgroundColor: UIColor? = nil,
    topColor: UIColor? = nil,
    bottomColor: UIColor? = nil) {
    let min = Int(duration / 60)
    let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
    self.durationText = String(format: "%02d:%02d", min, seconds)
    self.font = font
    self.textColor = textColor
    self.backgroundColor = backgroundColor
    self.topColor = topColor ?? .black0
    self.bottomColor = bottomColor ?? .black40
  }
}

class PlayDurationView: GradientView {
  private let durationLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.textColor = .white
  }

  override func initialize() {
    super.initialize()
    self.addSubview(self.durationLabel)

    self.topColor = UIColor.black0
    self.bottomColor = UIColor.black70
    self.axis = .vertical
  }

  override func setLayouts() {
    super.setLayouts()
    self.durationLabel.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(10)
      make.bottom.equalToSuperview().inset(6)
    }
  }

  func configure(with model: PlayDurationModel) {
    self.durationLabel.text = model.durationText
    self.durationLabel.textColor = model.textColor
    self.durationLabel.font = model.font
    if let topColor = model.topColor, let bottomColor = model.bottomColor {
      self.topColor = topColor
      self.bottomColor = bottomColor
    } else if let color = model.backgroundColor {
      self.backgroundColor = color
    }
  }
}
