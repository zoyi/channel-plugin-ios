//
//  BaseController.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 14..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import UINavigationItem_Margin

class BaseViewController: UIViewController {

  // MARK: Initializing

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required convenience init?(coder aDecoder: NSCoder) {
    self.init()
  }

  // MARK: Layout Constraints

  private(set) var didSetupConstraints = false

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.leftMargin = 0
    self.navigationItem.rightMargin = 0
    self.view.setNeedsUpdateConstraints()
  }

  override func updateViewConstraints() {
    if !self.didSetupConstraints {
      self.setupConstraints()
      self.didSetupConstraints = true
    }
    super.updateViewConstraints()
  }

  func setupConstraints() {
    // Override point
  }
}
