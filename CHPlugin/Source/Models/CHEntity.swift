//
//  Entity.swift
//  CHPlugin
//
//  Created by Haeun Chung on 16/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation

protocol CHEntity : ModelType {
  var name: String { get set }
  var avatarUrl: String? { get set }
  var initial: String { get set }
  var color: String { get set }
}
