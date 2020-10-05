//
//  Message.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 18..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift
import MobileCoreServices
import AVFoundation
import Photos

enum MessageDeliveryState: String {
  // this three state mean thirdparty messenger state
  case sending
  case sent
  case failed
  
  // send fail state
  case networkError
  
  // message delete state
  case removed
}

enum MessageType {
  case Default
  case WelcomeMessage
  case DateDivider
  case UserInfoDialog
  case NewAlertMessage
  case UserMessage
  case Log
  case WebPage
  case Media
  case File
  case Profile
}

enum CHMessageTranslateState {
  case loading
  case failed
  
  case original
  case translated
}

struct CHMessage: ModelType {
  // ModelType
  var id: String = ""
  // Message
  var channelId: String = ""
  var chatType: ChatType!
  var chatId: String = ""
  var personType: PersonType!
  var personId: String = ""
  var title: String? = nil
  var plainText: String?
  var blocks: [CHMessageBlock] = []
  var translatedBlocks: [CHMessageBlock] = []
  var requestId: String?
  var profileBot: [CHProfileItem]? = []
  var action: CHAction? = nil
  var submit: CHSubmit? = nil
  var createdAt: Date
  var language: String = ""
  
  var files: [CHFile] = []
  var webPage: CHWebPage?
  var log: CHLog?
  var marketing: CHMarketing?
  var buttons: [CHLinkButton] = []
  
  // Dependencies
  var entity: CHEntity?
  var mutable: Bool = true
  
  // Used in only client
  var state: MessageDeliveryState?
  var messageType: MessageType = .Default
  
  var progress: CGFloat = 1

  // local
  var translateState: CHMessageTranslateState = .original
  var fileDictionary: [String:Any]?
  
  var readableDate: String {
    let updateComponents = Calendar.current.dateComponents(
      [.year, .month, .day], from: self.createdAt)
    guard let year = updateComponents.year else { return "" }
    guard let month = updateComponents.month else { return "" }
    guard let day = updateComponents.day else { return "" }
    
    return "\(year)-\(month)-\(day)"
  }
  
  var readableCreatedAt: String {
    let updateComponents = NSCalendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute], from: self.createdAt)
    let suffix = (updateComponents.hour ?? 0) >= 12 ? "PM" : "AM"
    
    var hours = 0
    if let componentHour = updateComponents.hour {
      hours = componentHour > 12 ? componentHour - 12 : componentHour
    }
    let minutes = updateComponents.minute ?? 0
    return String(format:"%d:%02d %@", hours, minutes, suffix)
  }
  
  var logMessage: String? {
    if self.log != nil && self.log?.action == "closed" {
      return CHAssets.localized("ch.review.require.preview")
    }
    return nil
  }

  var getCurrentBlocks: [CHMessageBlock] {
    if self.translateState == .translated {
      return self.translatedBlocks
    } else {
      return self.blocks
    }
  }
  
  var attributedText: NSAttributedString? {
    guard self.getCurrentBlocks.count != 0 else { return nil }
    
    let result = NSMutableAttributedString(string: "")
    for (index, block) in self.getCurrentBlocks.enumerated() {
      if let text = block.displayText {
        result.append(text)
        if index != self.getCurrentBlocks.count - 1 {
          result.append(NSMutableAttributedString(string: "\n"))
        }
      }
    }
    return result
  }
}

extension CHMessage: CHPopupDisplayable {
  var removed: Bool {
    return self.state == .removed
  }
  
  var writer: CHEntity? {
    return personSelector(
      state: mainStore.state,
      personType: self.personType,
      personId: self.personId
    )
  }
  
  var mobileExposureType: InAppNotificationType? {
    return self.marketing?.exposureType
  }
  
  var mkInfo: MarketingInfo? {
    guard let marketing = self.marketing else { return nil }
    return (marketing.type, marketing.id)
  }
}

extension CHMessage: ObjectMapper_Mappable {
  init(
    chatId: String,
    blocks: [CHMessageBlock],
    files: [CHFile] = [],
    webPage: CHWebPage? = nil,
    type: MessageType,
    entity: CHEntity? = nil,
    buttons: [CHLinkButton] = [],
    action: CHAction? = nil,
    createdAt:Date? = Date(),
    id: String? = nil) {
    let now = Date()
    let requestId = "\(UInt64(now.timeIntervalSince1970 * 1000))" + String.randomString(length: 4)
  
    self.id = id ?? requestId
    self.requestId = requestId
    self.chatId = chatId
    self.createdAt = createdAt ?? now
    self.messageType = type
    self.entity = entity
    self.action = action
    self.personId = entity?.id ?? ""
    self.personType = entity?.entityType
    self.progress = 1
    self.blocks = blocks
    self.files = files
    self.webPage = webPage
    self.buttons = buttons
  }
  
  init(
    chatId: String,
    message: String,
    type: MessageType,
    entity: CHEntity? = nil,
    action: CHAction? = nil,
    createdAt:Date? = Date(),
    id: String? = nil) {
    let now = Date()
    let requestId = "\(UInt64(now.timeIntervalSince1970 * 1000))" + String.randomString(length: 4)
    let trimmedMessage = message.trimmingCharacters(in: .newlines)

    self.id = id ?? requestId
    self.requestId = requestId
    self.chatId = chatId
    self.createdAt = createdAt ?? now
    self.messageType = type
    self.entity = entity
    self.action = action
    self.personId = entity?.id ?? ""
    self.personType = entity?.entityType
    self.progress = 1
    self.plainText = trimmedMessage
    
    if trimmedMessage != "" {
      let transform = CustomBlockTransform(
        config: CHMessageParserConfig(font: UIFont.systemFont(ofSize: 15))
      )
      let block = CHMessageBlock(
        type: .text,
        blocks: [],
        language: nil,
        value: trimmedMessage
      )
      if let transformed = transform.transformFromJSON(block) {
        self.blocks = [transformed]
      }
    }
  }
  
  init(
    chatId: String,
    user: CHUser,
    message: String,
    messageType: MessageType = .UserMessage) {
    let now = Date()
    let requestId = "\(UInt64(now.timeIntervalSince1970 * 1000))" + String.randomString(length: 4)
    let trimmedMessage = message.trimmingCharacters(in: .newlines)
    
    self.id = requestId
    self.chatType = .userChat
    self.chatId = chatId
    self.personType = .user
    self.personId = user.id
    self.requestId = requestId
    self.createdAt = now
    self.messageType = messageType
    self.progress = 1
    self.plainText = trimmedMessage
    
    if trimmedMessage != "" {
      let transform = CustomBlockTransform(
        config: CHMessageParserConfig(font: UIFont.systemFont(ofSize: 15))
      )
      
      if let displayText = transform.parser.parseText(trimmedMessage) {
        self.blocks = [
          CHMessageBlock(
            type: .text,
            value: trimmedMessage,
            displayText: displayText,
            isOnlyEmoji: transform.parser.listener?.isOnlyEmoji ?? false
          )
        ]
      }
    }
  }
  
  init(
    chatId: String,
    entity: CHEntity,
    title: String? = nil,
    message: NSAttributedString?) {
    let now = Date()
    let requestId = "\(UInt64(now.timeIntervalSince1970 * 1000))" + String.randomString(length: 4)
    let trimmedMessage = message?.string.trimmingCharacters(in: .newlines) ?? ""
    
    self.id = requestId
    self.chatType = .userChat
    self.chatId = chatId
    self.personType = entity.entityType
    self.personId = entity.id
    self.requestId = requestId
    self.createdAt = now
    self.progress = 1
    self.title = title
    self.messageType = self.contextType()
    self.plainText = trimmedMessage
    
    if trimmedMessage != "" {
      let transform = CustomBlockTransform(
        config: CHMessageParserConfig(font: UIFont.systemFont(ofSize: 15))
      )
      if let displayText = transform.parser.parseText(trimmedMessage) {
        self.blocks = [
          CHMessageBlock(
            type: .text,
            value: trimmedMessage,
            displayText: displayText,
            isOnlyEmoji: transform.parser.listener?.isOnlyEmoji ?? false
          )
        ]
      }
    }
  }
  
  init(chatId: String, user: CHUser, message: String = "", files: [CHFile] = []) {
    self.init(chatId: chatId, user: user, message: message, messageType: .Media)
    self.files = files
    self.progress = 0
  }
  
  init(chatId: String, user: CHUser, message: String = "", fileDictionary: [String:Any]?) {
    self.init(chatId: chatId, user: user, message: message, messageType: .Media)
    self.fileDictionary = fileDictionary
    self.progress = 0
  }
  
  init?(map: ObjectMapper_Map) {
    self.createdAt = Date()
  }
  
  mutating func mapping(map: ObjectMapper_Map) {
    id          <- map["id"]
    channelId   <- map["channelId"]
    chatType    <- map["chatType"]
    chatId      <- map["chatId"]
    personType  <- map["personType"]
    personId    <- map["personId"]
    title       <- map["title"]
    plainText   <- map["plainText"]
    blocks <- (map["blocks"], CustomBlockTransform(
      config: CHMessageParserConfig(font: UIFont.systemFont(ofSize: 15)))
    )
    state       <- map["state"]
    requestId   <- map["requestId"]
    files       <- map["files"]
    webPage     <- map["webPage"]
    log         <- map["log"]
    marketing   <- map["marketing"]
    createdAt   <- (map["createdAt"], CustomDateTransform())
    profileBot  <- map["profileBot"]
    action      <- map["action"]
    submit      <- map["submit"]
    language    <- map["language"]
    buttons     <- map["buttons"]
    
    messageType = self.contextType()
  }
  
  func contextType() -> MessageType {
    if self.log != nil && self.log?.action != "delete_message" {
      return .Log
    } else if !self.files.isEmpty {
      return .Media
    } else if let profiles = self.profileBot, profiles.count != 0 {
      return .Profile
    } else if self.webPage != nil {
      return .WebPage
    } else {
      return .Default
    }
  }
}

extension CHMessage {
  var sortedFiles: [CHFile] {
    var videos: [CHFile] = []
    var images: [CHFile] = []
    var others: [CHFile] = []
    for file in self.files {
      if file.type == .video {
        videos.append(file)
      } else if file.type == .image {
        images.append(file)
      } else {
        others.append(file)
      }
    }
    return videos + images + others
  }
  
  var isOnlyEmoji: Bool {
    guard self.blocks.count != 0 else { return false }
    return self.blocks
      .map { $0.isOnlyEmoji }
      .reduce(true) { $0 && $1 }
  }
  
  func isEmpty() -> Bool {
    return self.blocks.count == 0 
  }
  
  func isSameWriter(other message: CHMessage?) -> Bool {
    return (self.personId == message?.personId
      && self.personType == message?.personType)
  }
  
  func isSameDate(other message: CHMessage?) -> Bool {
    guard let message = message else { return false }
    return NSCalendar.current.isDate(self.createdAt, inSameDayAs: message.createdAt)
  }
  
  func isContinue(other message: CHMessage?) -> Bool {
    guard let message = message else { return false }
    
    let calendar = NSCalendar.current
    let previousHour = calendar.component(.hour, from: message.createdAt)
    let currentHour = calendar.component(.hour, from: self.createdAt)
    let previousMin = calendar.component(.minute, from: message.createdAt)
    let currentMin = calendar.component(.minute, from: self.createdAt)
    
    if previousHour == currentHour
      && previousMin == currentMin
      && self.isSameWriter(other: message) {
      return true
    }
    
    return false
  }
}

//MARK: RestAPI

extension CHMessage {
  //TODO: refactor async call into actions 
  //but to do that, it also has to handle errors in redux
  
  static func createLocal(
    chatId: String,
    text: String?,
    originId: String? = nil,
    key: String? = nil,
    mutable: Bool = true) -> CHMessage {
    let me = mainStore.state.user
    var message = CHMessage(
      chatId: chatId,
      user: me,
      message: text ?? "",
      messageType: .UserMessage)
    if let originId = originId, let key = key {
      message.submit = CHSubmit(id: originId, key: key)
    }
    message.mutable = mutable
    return message
  }

  func isMine() -> Bool {
    let me = mainStore.state.user
    return self.entity?.id == me.id
  }
  
  func updateProfile(with key: String, value: Any) -> _RXSwift_Observable<CHMessage> {
    return UserChatPromise.updateMessageProfile(
      userChatId: self.chatId,
      messageId: self.id,
      key: key,
      value: value
    )
  }
  
  func send() -> _RXSwift_Observable<CHMessage> {
    return _RXSwift_Observable.create { subscriber in
      let disposable = UserChatPromise.createMessage(
        userChatId: self.chatId,
        message: self.plainText,
        requestId: self.requestId ?? "",
        files: self.files,
        fileDictionary: self.fileDictionary,
        submit: self.submit,
        mutable: self.mutable)
        .observeOn(_RXSwift_MainScheduler.instance)
        .subscribe(onNext: { (message) in
          subscriber.onNext(message)
        }, onError: { (error) in
          subscriber.onError(error)
        })
      
      return _RXSwift_Disposables.create {
        disposable.dispose()
      }
    }
  }
  
  func translate(to language: String) -> _RXSwift_Observable<[CHMessageBlock]> {
    return UserChatPromise.translate(
      userChatId: self.chatId,
      messageId: self.id,
      language: language
    )
  }
}

extension CHMessage: Equatable {}

func ==(lhs: CHMessage, rhs: CHMessage) -> Bool {
  return lhs.id == rhs.id &&
    lhs.messageType == rhs.messageType &&
    lhs.progress == rhs.progress &&
    lhs.files == rhs.files &&
    lhs.state == rhs.state &&
    lhs.webPage == rhs.webPage &&
    lhs.marketing == rhs.marketing &&
    lhs.plainText == rhs.plainText &&
    lhs.blocks == rhs.blocks &&
    lhs.translateState == rhs.translateState &&
    lhs.action?.closed == rhs.action?.closed &&
    lhs.profileBot == rhs.profileBot
}
