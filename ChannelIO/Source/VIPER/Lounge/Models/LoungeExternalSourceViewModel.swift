//
//  LoungeExternalSourceViewModel.swift
//  ChannelIO
//
//  Created by Haeun Chung on 30/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

enum CHExternalSourceType: String {
  case kakao = "appKakaoLink"
  case talktalk
  case facebook
  case email
  case phone
  case link
  
  var image: UIImage? {
    switch self {
    case .kakao: return CHAssets.getImage(named: "integrationKakao")
    case .talktalk: return CHAssets.getImage(named: "integrationTalktalk")
    case .facebook: return CHAssets.getImage(named: "integrationFbmsg")
    case .email: return CHAssets.getImage(named: "integrationEmail")
    case .phone: return CHAssets.getImage(named: "integrationPhone")
    case .link: return CHAssets.getImage(named: "integrationLink")
    }
  }
}

struct LoungeExternalSourceModel {
  var type: CHExternalSourceType
  var value: String
  
  static func generate(with channel: CHChannel, plugin: CHPlugin, thirdParties: [CHExternalSourceType: String]?) -> [LoungeExternalSourceModel] {
    var sources: [LoungeExternalSourceModel] = []
    
    if let thirdParties = thirdParties {
      for (thirdParty, link) in thirdParties {
        sources.append(LoungeExternalSourceModel(type: thirdParty, value: link))
      }
    }
    
    if plugin.id == channel.defaultPluginId {
      sources.append(LoungeExternalSourceModel(type: .link, value: channel.defaultPluginLink))
    }
    
    if let phoneNumber = channel.phoneNumber {
      sources.append(LoungeExternalSourceModel(type: .phone, value: "tel://\(phoneNumber)"))
    }
    return sources
  }
}
