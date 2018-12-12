//
//  CHNudge.swift
//  ch-desk-ios
//
//  Created by R3alFr3e on 5/2/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift

struct CHNudge: CHEvaluatable {
  var id: String = ""
  var channelId: String = ""
  var pluginId: String = ""
  var run: Bool = false
  var runOnAway: Bool = false
  var name: String = ""
  var target: [[CHTargetCondition]]? = nil
  var originalWeight: Float = 0
  var goalEventName: String? = nil
  var goalTtl: Int = 0
  var triggerEvent: String = ""
  var triggerDelay: Int = 0
  var repeatReachRateBase: Int = 0
  
  var startAt: Date? = nil
  var endAt: Date? = nil
  var createdAt: Date? = nil
  var updatedAt: Date? = nil
  
  //dep
  var plugin: CHPlugin? = nil
  var variants: [CHNudgeVariant]? = nil
  //var stats: [CHNudgeStat]? = nil
  var totalWeight : Float {
    guard let variants = variants else { return originalWeight }
    return variants.map({ $0.weight }).reduce(originalWeight, +)
  }
  
  static func createChat(nudgeId: String) -> Observable<ChatResponse> {
    return NudgePromise.createNudgeUserChat(nudgeId: nudgeId)
  }
}

extension CHNudge: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    id                  <- map["id"]
    channelId           <- map["channelId"]
    pluginId            <- map["pluginId"]
    run                 <- map["run"]
    runOnAway           <- map["runOnAway"]
    name                <- map["name"]
    target              <- map["target"]
    originalWeight      <- map["originalWeight"]
    goalEventName       <- map["goalEventName"]
    goalTtl             <- map["goalTtl"]
    triggerEvent        <- map["triggerEvent"]
    triggerDelay        <- map["triggerDelay"]
    repeatReachRateBase <- map["repeatReachRateBase"]
    startAt             <- (map["startAt"], CustomDateTransform())
    updatedAt           <- (map["endAt"], CustomDateTransform())
    createdAt           <- (map["createdAt"], CustomDateTransform())
    updatedAt           <- (map["updatedAt"], CustomDateTransform())
  }
}

extension CHNudge: Equatable {
  static func == (lhs: CHNudge, rhs: CHNudge) -> Bool {
    return lhs.run == rhs.run && lhs.id == rhs.id &&
      lhs.name == rhs.name &&
      lhs.originalWeight == rhs.originalWeight &&
      lhs.goalEventName == rhs.goalEventName &&
      lhs.goalTtl == rhs.goalTtl &&
      lhs.triggerEvent == rhs.triggerEvent &&
      lhs.triggerDelay == rhs.triggerDelay &&
      lhs.updatedAt == rhs.updatedAt &&
      lhs.repeatReachRateBase == rhs.repeatReachRateBase &&
      lhs.startAt == rhs.startAt &&
      lhs.endAt == rhs.endAt
  }
}

protocol CHImageable {
  var imageMeta: CHImageMeta? { get set }
  var imageUrl: String? { get set }
  var imageRedirectUrl: String? { get set }
}

struct CHNudgeVariant: CHImageable {
  var id: String = ""
  var nudgeId: String = ""
  var name: String = ""
  var title: String? = nil
  var message: NSAttributedString? = nil
  var botName: String = ""
  var weight: Float = 0
  var imageKey: String = ""
  var imageMeta: CHImageMeta? = nil
  var imageUrl: String? = nil
  var imageThumb: CHImageMeta? = nil
  var imageRedirectUrl: String? = nil
  
  var attachment: CHAttachmentType? = nil
  var buttonTitle: String? = nil
  var buttonRedirectUrl: String? = nil
  var createdAt: Date? = nil
  var updatedAt: Date? = nil
  
  //dep
  var bot: CHBot? = nil
  //var stat: CHNudgeStat? = nil
}

extension CHNudgeVariant : Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    id                <- map["id"]
    nudgeId           <- map["nudgeId"]
    name              <- map["name"]
    title             <- map["title"]
    attachment        <- map["attachment"]
    buttonTitle       <- map["buttonTitle"]
    buttonRedirectUrl <- map["buttonRedirectUrl"]
    message           <- (map["message"], CustomMessageTransform())
    weight            <- map["weight"]
    botName           <- map["botName"]
    imageKey          <- map["imageKey"]
    imageMeta         <- map["imageMeta"]
    imageRedirectUrl  <- map["imageRedirectUrl"]
    imageUrl          <- map["imageUrl"]
    imageThumb        <- map["imageThumb"]
    createdAt         <- (map["createdAt"], CustomDateTransform())
    updatedAt         <- (map["updatedAt"], CustomDateTransform())
  }
}

extension CHNudgeVariant: Equatable {
  static func == (lhs: CHNudgeVariant, rhs: CHNudgeVariant) -> Bool {
    return lhs.id == rhs.id &&
      lhs.imageThumb == rhs.imageThumb &&
      lhs.botName == rhs.botName &&
      lhs.weight == rhs.weight &&
      lhs.name == rhs.name &&
      lhs.message == rhs.message &&
      lhs.attachment == rhs.attachment &&
      lhs.buttonTitle == rhs.buttonTitle &&
      lhs.buttonRedirectUrl == rhs.buttonRedirectUrl
  }
}
