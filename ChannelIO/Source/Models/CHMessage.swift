//
//  Message.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 18..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift
import MobileCoreServices
import AVFoundation
import Photos

enum SendingState {
  case New, Sent, Failed
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
  case Action
  case Buttons
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
  var message: String?
  var messageV2: NSAttributedString?
  var requestId: String?
  var profileBot: [CHProfileItem]? = []
  var action: CHAction? = nil
  var buttons: [CHLink]? = []
  var submit: CHSubmit? = nil
  var createdAt: Date

  var language: String = ""
  
  var file: CHFile?
  var webPage: CHWebPage?
  var log: CHLog?
  
  // Dependencies
  var entity: CHEntity?
  var mutable: Bool = true
  // Used in only client
  var state: SendingState = .Sent
  var messageType: MessageType = .Default
  
  var progress: CGFloat = 1
  //var isRemote = true
  var onlyEmoji: Bool = false
  
  var translateState: CHMessageTranslateState = .original
  var translatedText: NSAttributedString? = nil
  
  var readableDate: String {
    let updateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self.createdAt)
    guard let year = updateComponents.year else { return "" }
    guard let month = updateComponents.month else { return "" }
    guard let day = updateComponents.day else { return "" }
    
    return "\(year)-\(month)-\(day)"
  }
  
  var readableCreatedAt: String {
    let updateComponents = NSCalendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.createdAt)
    let suffix = (updateComponents.hour ?? 0) >= 12 ? "PM" : "AM"
    
    var hours = 0
    if let componentHour = updateComponents.hour {
      hours = componentHour > 12 ? componentHour - 12 : componentHour
    }
    let minutes = updateComponents.minute ?? 0
    return String(format:"%d:%02d %@", hours, minutes, suffix)
  }
  
  var logMessage: String? {
    if self.file?.isPreviewable == true {
      return CHAssets.localized("ch.notification.upload_image.description")
    } else if self.file != nil {
      return CHAssets.localized("ch.notification.upload_file.description")
    } else if self.log != nil && self.log?.action == "closed" {
      return CHAssets.localized("ch.review.require.preview")
    }
    return nil
  }
  
  var isWelcome: Bool {
//    if let option = self.botOption, option["welcome"] == true {
//      return true
//    } else {
//      return false
//    }
    return false
  }

  var isDeleted: Bool {
    return self.log?.action == "delete_message"
  }
}

extension CHMessage: Mappable {
  init(chatId: String,
       message: String,
       type: MessageType,
       entity: CHEntity? = nil,
       action: CHAction? = nil,
       file: CHFile? = nil,
       createdAt:Date? = Date(),
       id: String? = nil) {
    let now = Date()
    let requestId = "\(UInt64(now.timeIntervalSince1970 * 1000))" + String.randomString(length: 4)
    let trimmedMessage = message.trimmingCharacters(in: .newlines)
    
    self.id = id ?? requestId
    self.message = trimmedMessage
    (self.messageV2, self.onlyEmoji) = CustomMessageTransform.markdown.parse(trimmedMessage)
    self.requestId = requestId
    self.chatId = chatId
    self.createdAt = createdAt ?? now
    self.messageType = type
    self.entity = entity
    self.action = action
    self.file = file
    self.personId = entity?.id ?? ""
    self.personType = entity?.entityType
    self.progress = 1
  }
  
  init(chatId: String, user: CHUser, message: String, messageType: MessageType = .UserMessage) {
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
    self.state = .New
    self.messageType = messageType
    self.progress = 1
    self.message = self.format(message: trimmedMessage)
    (self.messageV2, self.onlyEmoji) = CustomMessageTransform.markdown.parse(trimmedMessage)
  }
  
  init(chatId: String,
       entity: CHEntity,
       title: String? = nil,
       message: NSAttributedString?,
       file: CHFile? = nil,
       buttons: [CHLink]? = nil) {
    let now = Date()
    let requestId = "\(UInt64(now.timeIntervalSince1970 * 1000))" + String.randomString(length: 4)
    
    self.id = requestId
    self.chatType = .userChat
    self.chatId = chatId
    self.personType = entity.entityType
    self.personId = entity.id
    self.requestId = requestId
    self.createdAt = now
    self.state = .New
    self.progress = 1
    self.buttons = buttons
    self.title = title
    self.file = file
    self.messageV2 = message
    self.messageType = CHMessage.contextType(self)
  }
  
  init(chatId: String, user: CHUser, message: String = "", asset: PHAsset? = nil, image: UIImage? = nil) {
    self.init(chatId: chatId, user: user, message: message, messageType: .Media)
    if let image = image {
      self.file = CHFile(imageData: image)
    } else if let asset = asset {
      self.file = CHFile(asset: asset)
    }
    
    self.messageType = self.file?.mimeType == .image || self.file?.mimeType == .gif ? .Media : .File
    self.progress = 0
  }
  
  init?(map: Map) {
    self.createdAt = Date()
  }
  
  mutating func mapping(map: Map) {
    id          <- map["id"]
    channelId   <- map["channelId"]
    chatType    <- map["chatType"]
    chatId      <- map["chatId"]
    personType  <- map["personType"]
    personId    <- map["personId"]
    title       <- map["title"]
    message     <- map["message"]
    requestId   <- map["requestId"]
    file        <- map["file"]
    webPage     <- map["webPage"]
    buttons     <- map["buttons"]
    log         <- map["log"]
    createdAt   <- (map["createdAt"], CustomDateTransform())
    profileBot  <- map["profileBot"]
    action      <- map["action"]
    submit      <- map["submit"]
    language    <- map["language"]
    
    let msgv2 = map["message"].currentValue as? String ?? ""
    (messageV2, onlyEmoji) = CustomMessageTransform.markdown.parse(msgv2)
    
    if self.action != nil {
      messageType = .Action
    } else {
      messageType = CHMessage.contextType(self)
    }
    
    if self.isDeleted {
      self.message = MessageFactory.deleted().string
      self.messageV2 = MessageFactory.deleted()
    }
  }
  
  func format(message: String) -> String {
    var filterText = message
    filterText = filterText.replacingOccurrences(of: "<", with: "\\<")
    filterText = filterText.replacingOccurrences(of: ">", with: "\\>")
    filterText = filterText.replacingOccurrences(of: "]", with: "\\]")
    filterText = filterText.replacingOccurrences(of: "[", with: "\\[")
    return filterText
  }
  
  static func contextType(_ message: CHMessage) -> MessageType {
     if message.log != nil && message.log?.action != "delete_message" {
      return .Log
    } else if let buttons = message.buttons, buttons.count != 0 {
      return .Buttons
    } else if message.file?.image == true {
      return .Media
    } else if message.file != nil {
      return .File
    } else if let profiles = message.profileBot, profiles.count != 0 {
      return .Profile
    } else if message.webPage != nil {
      return .WebPage
    } else {
      return .Default
    }
  }
}

extension CHMessage {
  func isEmpty() -> Bool {
    if let messageV2 = self.messageV2?.string, messageV2 != "" {
      return false
    } else if let message = self.message, message != "" {
      return false
    } else {
      return true
    }
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
    var message = CHMessage(chatId: chatId, user: me, message: text ?? "")
    if let originId = originId, let key = key {
      message.submit = CHSubmit(id: originId, key: key)
    }
    message.mutable = mutable
    return message
  }
  
  static func getMessages(
    userChatId: String,
    since: String,
    limit: Int,
    sortOrder:String) -> Observable<[String: Any]> {
    
    return UserChatPromise.getMessages(
      userChatId: userChatId,
      since: since,
      limit: limit,
      sortOrder: sortOrder)
  }
  
  func isMine() -> Bool {
    let me = mainStore.state.user
    return self.entity?.id == me.id
  }
  
  func updateProfile(with key: String, value: Any) -> Observable<CHMessage> {
    return UserChatPromise.updateMessageProfile(messageId: self.id, key: key, value: value)
  }
  
  func send() -> Observable<CHMessage> {
    if self.file != nil {
      if let mimeType = self.file?.mimeType {
        switch mimeType {
        case .image:
          return self.sendImage()
        case .gif:
          return self.sendGif()
        case .video:
          return self.sendVideo()
        default:
          return self.sendImage()
        }
      }
      return self.sendText()
    } else {
      return self.sendText()
    }
  }
  
  func sendFile() -> Observable<CHMessage> {
    return Observable.create{ subscriber in
      guard let file = self.file, file.rawData != nil || file.asset != nil else {
        subscriber.onError(CHErrorPool.sendFileError)
        return Disposables.create()
      }
      
      var signal: Disposable?
      if let asset = file.asset, let mimeType = file.mimeType {
        asset.fetchVideo(completion: { (asset, mix, info) in
          if let asset = asset as? AVURLAsset {
            let data = try! Data(contentsOf: asset.url)
            signal = self.send(data: data, fileName: "Channel_File", mimeType: mimeType)
              .subscribe(onNext: { (message) in
                subscriber.onNext(message)
              }, onError: { (error) in
                subscriber.onError(error)
              })
          }
        })
      }

      return Disposables.create {
        signal?.dispose()
      }
    }
  }
  
  func sendText() -> Observable<CHMessage> {
    return Observable.create { subscriber in
      let disposable = UserChatPromise.createMessage(
        userChatId: self.chatId,
        message: self.message ?? "",
        requestId: self.requestId!,
        submit: self.submit,
        mutable: self.mutable).subscribe(onNext: { (message) in
          subscriber.onNext(message)
        }, onError: { (error) in
          subscriber.onError(error)
        })
      
      return Disposables.create(with: {
        disposable.dispose()
      })
    }
  }
  
  private func sendGif() -> Observable<CHMessage> {
    return Observable.create({ (subscriber) in
      guard let file = self.file, let asset = file.asset else {
        subscriber.onError(CHErrorPool.sendFileError)
        return Disposables.create()
      }
      
      var signal: Disposable?
      asset.fetchImageData(completion: { (data, uti, orientation, info) in
        signal = self.send(
          data: data,
          fileName: "Channel_Gif_Photo_\(Date().fullDateString()).gif",
          mimeType: file.mimeType).subscribe(onNext: { (message) in
            subscriber.onNext(message)
          }, onError: { (error) in
            subscriber.onError(error)
          })
      })

      return Disposables.create {
        signal?.dispose()
      }
    })
  }
  
  private func sendImage() -> Observable<CHMessage> {
    return Observable.create({ (subscriber) in
      guard let file = self.file, file.image else {
        subscriber.onError(CHErrorPool.sendFileError)
        return Disposables.create()
      }
      
      var signal: Disposable?
      let fileName = "Channel_Photo_\(Date().fullDateString()).png"
      if let asset = file.asset {
        asset.fetchImageData(completion: { (data, uti, orientation, info) in
          guard let data = data, let image = UIImage(data: data) else {
            subscriber.onError(CHErrorPool.sendFileError)
            return
          }
          signal = self.send(
            data: image.jpegData(compressionQuality: 1.0),
            fileName: fileName,
            mimeType: file.mimeType).subscribe(onNext: { (message) in
              subscriber.onNext(message)
              subscriber.onCompleted()
            }, onError: { (error) in
              subscriber.onError(error)
            })
        })
      } else if let image = file.imageData {
        signal = self.send(
          data: image.jpegData(compressionQuality:1.0),
          fileName: fileName,
          mimeType: file.mimeType).subscribe(onNext: { (message) in
            subscriber.onNext(message)
            subscriber.onCompleted()
          }, onError: { (error) in
            subscriber.onError(error)
          })
      }

      return Disposables.create {
        signal?.dispose()
      }
    })
  }
  
  private func sendVideo() -> Observable<CHMessage> {
    return Observable.create({ (subscriber) in
      guard let file = self.file, let asset = file.asset else {
        subscriber.onError(CHErrorPool.sendFileError)
        return Disposables.create()
      }
      
      var signal: Disposable?
      asset.fetchVideo(completion: { (asset, mix, info) in
        if let asset = asset as? AVURLAsset {
          let data = try! Data(contentsOf: asset.url)
          signal = self.send(
            data: data,
            fileName: "Channel_Video_\(Date().fullDateString()).mp4",
            mimeType: file.mimeType).subscribe(onNext: { (message) in
              subscriber.onNext(message)
            }, onError: { (error) in
              subscriber.onError(error)
            })
          }
        })

      return Disposables.create {
        signal?.dispose()
      }
    })
  }
  
  private func send(data: Data?, fileName: String? = "", mimeType: Mimetype?) -> Observable<CHMessage> {
    return Observable.create({ (subscriber) in
      guard let data = data, let mimeType = mimeType else {
        subscriber.onError(CHErrorPool.sendFileError)
        return Disposables.create()
      }
      
      let disposable = UserChatPromise.uploadFile(
        name: fileName,
        file: data,
        requestId: self.requestId!,
        userChatId: self.chatId,
        mimeType: mimeType)
        .subscribe(onNext: { (message) in
          subscriber.onNext(message)
        }, onError: { (error) in
          subscriber.onError(error)
        })
      
      return Disposables.create {
        disposable.dispose()
      }
    })
  }
  
  func translate(to language: String) -> Observable<String?> {
    return UserChatPromise.translate(
      messageId: self.id,
      language: language)
  }
}

extension CHMessage: Equatable {}

func ==(lhs: CHMessage, rhs: CHMessage) -> Bool {
  return lhs.id == rhs.id &&
    lhs.messageType == rhs.messageType &&
    lhs.progress == rhs.progress &&
    lhs.file?.downloaded == rhs.file?.downloaded &&
    lhs.state == rhs.state &&
    lhs.webPage == rhs.webPage &&
    lhs.message == rhs.message &&
    lhs.translateState == rhs.translateState &&
    lhs.action?.closed == rhs.action?.closed
}
