//
//  ChatFileQueueItem.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/05.
//

import Alamofire
import Photos
import RxSwift

class ChatFileQueueItem: ChatQueueBaseItem {
  var name: String = ""

  var data: Data?
  var url: String?
  var contentType: String = ""
  var fileType: FileType {
    set { dbFileType = newValue.rawValue }
    get { return FileType(rawValue: dbFileType) ?? .image }
  }
  var dbFileType: String = FileType.file.rawValue
  var file: CHFile!
  var jsonString: [String:Any]?
  var completion: (([String:Any]?) -> ())?
  
  private let disposeBag = DisposeBag()

  convenience init(
    channelId: String,
    type: ChatType,
    chatId: String,
    id: String = "",
    file: CHFile,
    completion: (([String:Any]?) -> ())? = nil) {
    self.init()
    self.channelId = channelId
    self.chatType = type
    self.chatId = chatId
    self.requestedAt = Date()
    self.progress = 0.0
    self.id = file.id
    self.name = file.name
    self.status = .initial
    self.contentType = file.contentType ?? ""
    self.fileType = file.type
    self.file = file
    self.completion = completion
  }

  func prepare() -> Observable<ChatFileQueueItem> {
    return Observable.create { [weak self] subscriber in
      guard let self = self else {
        subscriber.onError(ChannelError.unknownError())
        return Disposables.create()
      }

      let signal = self.file
        .getData()
        .subscribe(onNext: { data, name in
          self.data = data
          if let name = name {
            self.name = name
          }
          subscriber.onNext(self)
          subscriber.onCompleted()
        })

      return Disposables.create {
        signal.dispose()
      }
    }
  }

  override func request() -> Observable<ChatQueuable> {
    guard let data = self.data else {
      return .error(ChannelError.entityError)
    }

    return Observable.create { [weak self] subscriber in
      guard let self = self else {
        subscriber.onError(ChannelError.unknownError())
        return Disposables.create()
      }

      let signal = CHFile
        .upload(
          channelId: self.channelId,
          filename: self.name,
          data: data
        )
        .observeOn(MainScheduler.asyncInstance)
        .throttle(
          .milliseconds(400),
          scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
        )
        .subscribe(onNext: { string, progress in
          self.progress = progress
          self.status = .progress
          if let string = string {
            self.jsonString = string
          }
          subscriber.onNext(self)
        }, onError: { error in
          self.status = .error
          subscriber.onError(error)
        }, onCompleted: {
          self.status = .completed
          subscriber.onCompleted()
          if let jsonString = self.jsonString, let completion = self.completion {
            completion(jsonString)
          }
        })

      return Disposables.create {
        signal.dispose()
      }
    }
  }

  static func == (lhs: ChatFileQueueItem, rhs: ChatFileQueueItem) -> Bool {
    return lhs.channelId == rhs.channelId &&
      lhs.chatType == rhs.chatType &&
      lhs.chatId == rhs.chatId &&
      lhs.progress == rhs.progress &&
      lhs.status == rhs.status &&
      lhs.url == rhs.url
  }
}
