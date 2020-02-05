//
//  LoungeExternalSourceViewModel.swift
//  ChannelIO
//
//  Created by Haeun Chung on 30/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

enum CHExternalSourceType: String {
  case thirdParty
  case email
  case phone
  case link
}

struct LoungeExternalSourceModel {
  var type: CHExternalSourceType
  var image: UIImage?
  var value: String
  
  static func generate(with channel: CHChannel, plugin: CHPlugin, appMessengers: [CHAppMessenger]) -> [LoungeExternalSourceModel] {
    var sources: [LoungeExternalSourceModel] = []
    
    for appMessenger in appMessengers {
      if let imageUrl = appMessenger.iconUrl,
        let data = try? Data(contentsOf: imageUrl){
        sources.append(LoungeExternalSourceModel(
          type: .thirdParty,
          image: UIImage(data: data),
          value: appMessenger.name
        ))
      }
    }
    
    if let phoneNumber = channel.phoneNumber {
      sources.append(LoungeExternalSourceModel(
        type: .phone,
        image: CHAssets.getImage(named: "integrationPhone"),
        value: "tel://\(phoneNumber)"
      ))
    }

    if plugin.id == channel.defaultPluginId, channel.domain != "" {
      sources.append(LoungeExternalSourceModel(
        type: .link,
        image: CHAssets.getImage(named: "integrationLink"),
        value: channel.defaultPluginLink
      ))
    }
    
    return sources
  }
}
