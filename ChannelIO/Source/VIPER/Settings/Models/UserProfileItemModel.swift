//
//  UserProfileItemModel.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

struct UserProfileItemModel: Equatable {
  var profileNamei18n: CHi18n? = nil
  var profileType: ProfileSchemaType = .string
  var profileValue: Any? = nil

  var rawData: CHProfileSchema

  func getProfileName(with config: CHMessageParserConfig?) -> NSAttributedString? {
    return self.profileNamei18n?.getAttributedMessage(with: config)
  }
  
  static func generate(from profiles: [String: Any]?, schemas: [CHProfileSchema]) -> [UserProfileItemModel] {
    return schemas.map { (schema) in
      return UserProfileItemModel(
        profileNamei18n: schema.nameI18n,
        profileType: schema.type,
        profileValue: profiles?[schema.key],
        rawData: schema
      )
    }
  }
  
  static func == (lhs:UserProfileItemModel, rhs:UserProfileItemModel) -> Bool {
    if lhs.profileType != rhs.profileType {
      return false
    }
    if lhs.profileType == .string,
      let lValue = lhs.profileValue as? String,
      let rValue = lhs.profileValue as? String {
      return lValue == rValue && lhs.profileNamei18n == rhs.profileNamei18n
    }
    else if lhs.profileType == .number,
      let lValue = lhs.profileValue as? Int,
      let rValue = lhs.profileValue as? Int {
      return lValue == rValue && lhs.profileNamei18n == rhs.profileNamei18n
    }
    return lhs.profileValue == nil && rhs.profileValue == nil
  }
}
