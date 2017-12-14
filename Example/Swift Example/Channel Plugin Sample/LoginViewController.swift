//
//  LoginViewController.swift
//  Example
//
//  Created by Haeun Chung on 14/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController : UIViewController {
  @IBOutlet var idField: UITextField!
  @IBOutlet var usernameField: UITextField!
  @IBOutlet var phoneField: UITextField!
  @IBOutlet var loginButton: UIButton!
  @IBOutlet var warningLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.idField.placeholder = "user Id"
    self.usernameField.placeholder = "user name (optional)"
    self.phoneField.placeholder = "mobile number (optional)"
    self.warningLabel.text = ""
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destinationVC = segue.destination as? MainViewController {
      destinationVC.isUser = true
      destinationVC.userId = self.idField.text ?? ""
      destinationVC.userName = self.usernameField.text ?? ""
      destinationVC.phoneNumber = self.phoneField.text ?? ""
    }
  }
  
  @IBAction func didClickOnLogin() {
    self.idField.resignFirstResponder()
    self.usernameField.resignFirstResponder()
    self.phoneField.resignFirstResponder()
    
    if let id = self.idField.text {
      self.warningLabel.text = ""
      self.performSegue(withIdentifier: "MainViewSegue", sender: id)
    } else {
      self.warningLabel.text = "id is required to login as user"
    }
  }
}

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.idField.resignFirstResponder()
    self.usernameField.resignFirstResponder()
    self.phoneField.resignFirstResponder()
    return true
  }
}
