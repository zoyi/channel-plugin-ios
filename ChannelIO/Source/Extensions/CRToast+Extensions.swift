//
//  CRToast+Extensions.swift
//  CHPlugin
//
//  Created by R3alFr3e on 5/22/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import CRToast
import ObjectMapper
import SwiftyJSON

extension CRToastManager {
  static func showErrorFromData(_ data: Data?) {
    guard let data = data else { return }
    
    let json = SwiftyJSON.JSON(data)
    
    guard let errors: [CHError] = Mapper<CHError>()
      .mapArray(JSONObject: json["errors"].object) else {
      return
    }
    
    errors.forEach { error -> Void in
      dispatch {
        CRToastManager.dismissAllNotifications(false)
        CRToastManager.showErrorMessage(error.message)
      }
    }
  }
  
  static func showErrorMessage(_ message: String) {
    dispatch {
      CRToastManager.dismissNotification(false)
      CRToastManager.showNotification(withMessage: message, completionBlock: nil)
    }
  }
}
