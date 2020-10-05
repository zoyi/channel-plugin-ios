//
//  CHFieldProtocols.swift
//  ChannelIO
//
//  Created by 김진학 on 2020/07/22.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift

protocol CHFieldDelegate: class {
  func getText() -> String
  func setText(_ value: String)
  func isValid() -> _RXSwift_Observable<Bool>
  func hasChanged() -> _RXSwift_Observable<String>
}

enum EditFieldType {
  case name
  case phone
  case text
  case number
  case date
  case boolean
}

enum EntityType {
  case user
  case none
}
