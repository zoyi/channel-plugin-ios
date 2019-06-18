//
//  GuestProfileItemModel.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

struct GuestProfileItemModel: Equatable {
  var profileName: String = ""
  var profileType: ProfileSchemaType = .string
  var profileValue: Any? = nil

  var rawData: CHProfileSchema
  
  static func generate(from profiles: [String: Any]?, schemas: [CHProfileSchema]) -> [GuestProfileItemModel] {
    return schemas.map({ (schema) in
      return GuestProfileItemModel(
        profileName: schema.nameI18n?.getMessage() ?? "",
        profileType: schema.type,
        profileValue: profiles?[schema.key],
        rawData: schema
      )
    })
  }
  
  static func == (lhs:GuestProfileItemModel, rhs:GuestProfileItemModel) -> Bool {
    if lhs.profileType != rhs.profileType {
      return false
    }
    if lhs.profileType == .string, let lValue = lhs.profileValue as? String, let rValue = lhs.profileValue as? String {
      return lValue == rValue && lhs.profileName == rhs.profileName
    }
    else if lhs.profileType == .number, let lValue = lhs.profileValue as? Int, let rValue = lhs.profileValue as? Int {
      return lValue == rValue && lhs.profileName == rhs.profileName
    }
    return lhs.profileValue == nil && rhs.profileValue == nil
  }
}
