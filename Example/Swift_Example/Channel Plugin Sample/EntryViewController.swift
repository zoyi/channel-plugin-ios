//
//  EntryViewController.swift
//  Example
//
//  Created by Haeun Chung on 14/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import UIKit

class EntryViewController : UIViewController {
  @IBOutlet var veilButton: UIButton!
  @IBOutlet var userButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIApplication.shared.statusBarStyle = .lightContent
  }
}
