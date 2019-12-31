//
//  ChatQueueService.swift
//  ch-desk-ios
//
//  Created by intoxicated on 21/11/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import RxSwift

protocol ChatQueueServiceProtocol {
  var maxItemsPerQueue: Int { get set }

  func enqueue(item: ChatQueuable)
  func enqueue(items: [ChatQueuable])
  func cancel(item: ChatQueuable) -> Bool
  func cancel(key: ChatQueueKey) -> Bool
  func remove(item: ChatQueuable) -> Bool
  func removeAllItems(key: ChatQueueKey)
  func find(key: ChatQueueKey) -> ChatQueue?

  func progress() -> Observable<ChatQueuable>
  func completed() -> Observable<ChatQueuable>
  func progress(key: ChatQueueKey) -> Observable<ChatQueuable>
  func completed(key: ChatQueueKey) -> Observable<ChatQueuable>
  func error(key: ChatQueueKey) -> Observable<ChatQueuable>
  func status(key: ChatQueueKey) -> Observable<ChatQueueStatus>

  func clearAll()
}

class ChatQueueService: ChatQueueServiceProtocol {
  static let shared = ChatQueueService()

  var maxItemsPerQueue: Int = 20

  private var queue = DispatchQueue(label: "com.zoyi.channel.queue", qos: .background, attributes: .concurrent)

  private init() {}

  private var progressSignal = PublishSubject<ChatQueuable>()
  private var completionSignal = PublishSubject<ChatQueuable>()

  private var chatQueues: [ChatQueueKey: ChatQueue] = [:]
  private var disposeBag = DisposeBag()

  /**
   Find a queue object
   -
   - Parameter chatKey: a ChatQueueKey (chatType and chatId)
   - Returns: a optional `ChatQueue`
   */
  func find(key: ChatQueueKey) -> ChatQueue? {
    return self.createQueueIfNeeded(key: key)
  }

  /**
   Enqueue an item into queue
   -
   - Parameter item: a object confirming `ChatQueuable`
   */
  func enqueue(item: ChatQueuable) {
    let key = ChatQueueKey(chatType: item.chatType, chatId: item.chatId)
    let queue = self.createQueueIfNeeded(key: key)
    queue.enqueue(item: item)
  }

  /**
   Enqueue a list of items into queues
   -
   - Parameter items: array of `ChatQueuable`
   */
  func enqueue(items: [ChatQueuable]) {
    for item in items {
      self.enqueue(item: item)
    }
  }

  /**
   Cancel a item from its queue
   -
   - Parameter item: a `ChatQueuable`
   - Returns: True if successfully cancel, otherwise false
   */
  func cancel(item: ChatQueuable) -> Bool {
    let key = ChatQueueKey(chatType: item.chatType, chatId: item.chatId)
    if let queue = self.find(key: key) {
      queue.cancel(item: item)
      return true
    }
    return false
  }

  func remove(item: ChatQueuable) -> Bool {
    let key = ChatQueueKey(chatType: item.chatType, chatId: item.chatId)
    if let queue = self.find(key: key) {
      queue.remove(item: item)
      return true
    }
    return false
  }
  /**
   Cancel everyting in queue
   -
   - Parameter key: a `ChatQueueKey`
   - Returns: True if successfully cancel, otherwise false
   */
  func cancel(key: ChatQueueKey) -> Bool {
    if let queue = self.find(key: key) {
      queue.cancelAll()
      return true
    }
    return false
  }

  /**
   Cancel everything
   -
   */
  func cancelAll() {
    for (_, queue) in self.chatQueues {
      queue.cancelAll()
    }
  }

  /**
   Create a queue if not exist
   -
   - Parameter key: a  `ChatQueueKey`
   - Returns: a `ChatQueue` object
   */
  private func createQueueIfNeeded(key: ChatQueueKey, items: [ChatQueuable] = []) -> ChatQueue {
    if let queue = self.chatQueues[key] {
      return queue
    }
    let queue = self.createQueue(key: key, items: items)
    self.chatQueues[key] = queue
    return queue
  }

  /**
   Create a queue
   -
   - Parameter key: a  `ChatQueueKey`
   - Returns: a `ChatQueue` object
   */
  private func createQueue(key: ChatQueueKey, items: [ChatQueuable] = []) -> ChatQueue {
    let queue = ChatQueue(
      type: key.chatType,
      id: key.chatId,
      maxItems: self.maxItemsPerQueue,
      items: items
    )
    queue.signalForProgress()
      .bind(to: self.progressSignal)
      .disposed(by: self.disposeBag)
    queue.signalForCompletion()
      .bind(to: self.completionSignal)
      .disposed(by: self.disposeBag)

    return queue
  }

  /**
   Get signal status happens in queues
   -
   - Parameter key: a `ChatQueueKey`
   - Returns: Observable with `ChatQueuable`
   */
  func status(key: ChatQueueKey) -> Observable<ChatQueueStatus> {
    guard let queue = self.find(key: key) else {
      return .error(ChannelError.parameterError)
    }
    return queue.signalForStatus()
  }

  /**
   Get signal when any progress happens in queues
   -
   - Returns: Observable with `ChatQueuable`
   */
  func progress() -> Observable<ChatQueuable> {
    return self.progressSignal.asObservable()
  }

  /**
   Get signal when any completion happens in queues
   -
   - Returns: Observable with `ChatQueuable`
   */
  func completed() -> Observable<ChatQueuable> {
    return self.completionSignal.asObservable()
  }

  /**
   Get signal when any progress happens in queues
   -
   - Parameter key: a `ChatQueueKey`
   - Returns: Observable with `ChatQueuable`
   */
  func progress(key: ChatQueueKey) -> Observable<ChatQueuable> {
    //observe all reqId
    //once it all ends return
    guard let queue = self.find(key: key) else {
      return .error(ChannelError.parameterError)
    }

    return queue.signalForProgress()
  }

  /**
   Get signal when any completion happens in queues
   -
   - Parameter key: a `ChatQueueKey`
   - Returns: Observable with `ChatQueuable`
   */
  func completed(key: ChatQueueKey) -> Observable<ChatQueuable> {
    guard let queue = self.find(key: key) else {
      return .error(ChannelError.parameterError)
    }

    return queue.signalForCompletion()
  }

  func error(key: ChatQueueKey) -> Observable<ChatQueuable> {
    guard let queue = self.find(key: key) else {
      return .error(ChannelError.parameterError)
    }

    return queue.signalForError()
  }

  func removeAllItems(key: ChatQueueKey) {
    guard let queue = self.find(key: key) else {
      return
    }

    queue.removeAll()
  }
  /**
   Clear out all memory usage
   -
   */
  func clearAll() {
    self.cancelAll()
    self.chatQueues = [:]
    self.disposeBag = DisposeBag()
  }
}
