//
//  GuestProfileItemModel.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

struct GuestProfileItemModel {
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
}
