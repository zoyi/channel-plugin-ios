//
//  ChatQueue.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/05.
//

//import RxSwift

struct ChatQueueKey: Hashable {
  var chatType: ChatType
  var chatId: String

  static func == (lhs: ChatQueueKey, rhs: ChatQueueKey) -> Bool {
    return lhs.chatType == rhs.chatType && lhs.chatId == rhs.chatId
  }
}

enum ChatQueueStatus {
  case idle
  case enqueue(_ items: [ChatQueuable])
  case loading(_ items: [ChatQueuable])
  case error(_ error: ChannelError?, _ items: [ChatQueuable])
  case completed(_ items: [ChatQueuable])
}

protocol ChatQueueProtocol {
  var chatType: ChatType { get set }
  var chatId: String { get set }
  var maxItems: Int { get set }

  var items: [ChatQueuable] { get set }
  var signals: [String: _RXSwift_Disposable?] { get set }

  func find(reqId: String) -> ChatQueuable?
  func enqueue(item: ChatQueuable?)
  func execute(item: ChatQueuable?) -> Bool
  func cancel(item: ChatQueuable?)
  func remove(item: ChatQueuable?)
  func cancelAll()
  func removeAll()

  func signalForStatus() -> _RXSwift_Observable<ChatQueueStatus>
  func signalForProgress() -> _RXSwift_Observable<ChatQueuable>
  func signalForError() -> _RXSwift_Observable<ChatQueuable>
  func signalForCompletion() -> _RXSwift_Observable<ChatQueuable>
  func signalForProgress(reqId: String) -> _RXSwift_Observable<ChatQueuable>
  func signalForCompletion(reqId: String) -> _RXSwift_Observable<ChatQueuable>
}

class ChatQueue: ChatQueueProtocol {
  var channelId: String
  var chatType: ChatType
  var chatId: String
  var maxItems: Int
  var items: [ChatQueuable] = []
  var signals: [String: _RXSwift_Disposable?] = [:]

  private var disposeBag = _RXSwift_DisposeBag()

  private var progressSignal = _RXSwift_PublishSubject<ChatQueuable>()
  private var completionSignal = _RXSwift_PublishSubject<ChatQueuable>()
  private var errorSignal = _RXSwift_PublishSubject<ChatQueuable>()
  private var statusSignal = _RXSwift_PublishSubject<ChatQueueStatus>()

  init(type: ChatType, id: String, maxItems: Int = 20, items: [ChatQueuable] = []) {
    self.chatType = type
    self.chatId = id
    self.maxItems = maxItems
    self.channelId = PrefStore.getCurrentChannelId() ?? ""
    self.items = items.compactMap { item -> ChatFileQueueItem? in
      guard let item = item as? ChatFileQueueItem else { return nil }
      return item
    }
  }

  func enqueue(item: ChatQueuable?) {
    dispatchSyncOnBack {
      guard let item = item else { return }
      self.items.append(item)
      self.statusSignal.onNext(.enqueue(self.items))
      self.executeFisrtInitialItemIfNeeded()
    }
  }

  @discardableResult
  func execute(item: ChatQueuable?) -> Bool {
    guard let item = item else { return false }
    let disposal = item
      .request()
      .subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos: .background))
      .subscribe(onNext: { [weak self] updatedItem in
        guard let self = self else { return }
        self.progressSignal.onNext(updatedItem)
        self.statusSignal.onNext(.loading(self.items))
      }, onError: { [weak self] error in
        guard let self = self else { return }
        self.errorSignal.onError(ChannelError.networkError)
        self.statusSignal.onNext(.error(ChannelError.networkError, self.items))
        self.executeFisrtInitialItemIfNeeded()
      }, onCompleted: { [weak self] in
        guard let self = self else { return }
        self.completionSignal.onNext(item)
        self.statusSignal.onNext(.completed(self.items))
        self.remove(item: item)
      })

    self.signals[item.id] = disposal
    return true
  }

  func find(reqId: String) -> ChatQueuable? {
    return self.items.filter { $0.id == reqId }.first
  }
  
  func cancel(item: ChatQueuable?) {
    dispatchSyncOnBack {
      guard var item = item else { return }
      if let signal = self.signals[item.id] {
        signal?.dispose()
      }

      if let index = self.items.firstIndex(where: { $0.id == item.id }) {
        if item.status != .completed {
          item.status = .error
        }
        self.items[index] = item
      }
    }
  }

  func remove(item: ChatQueuable?) {
    dispatchSyncOnBack {
      guard let item = item else { return }
      if let signal = self.signals[item.id] {
        self.signals.removeValue(forKey: item.id)
        signal?.dispose()
      }

      if let index = self.items.firstIndex(where: { $0.id == item.id }) {
        self.items.remove(at: index)
      }
      
      self.executeFisrtInitialItemIfNeeded()
    }
  }

  func cancelAll() {
    dispatchSyncOnBack {
      self.items.forEach { self.cancel(item: $0) }
    }
  }

  func removeAll() {
    dispatchSyncOnBack {
      self.items.forEach { self.remove(item: $0) }
    }
  }

  func signalForProgress() -> _RXSwift_Observable<ChatQueuable> {
    return self.progressSignal.asObservable()
  }

  func signalForCompletion() -> _RXSwift_Observable<ChatQueuable> {
    return self.completionSignal.asObservable()
  }

  func signalForError() -> _RXSwift_Observable<ChatQueuable> {
    return self.errorSignal.asObservable()
  }

  func signalForStatus() -> _RXSwift_Observable<ChatQueueStatus> {
    return self.statusSignal.asObservable()
  }

  func signalForProgress(reqId: String) -> _RXSwift_Observable<ChatQueuable> {
    guard self.signals[reqId] != nil else {
      return .error(ChannelError.notFoundError)
    }
    return self.progressSignal.filter { $0.id == reqId }
  }

  func signalForCompletion(reqId: String) -> _RXSwift_Observable<ChatQueuable> {
    guard self.signals[reqId] != nil else {
      return .error(ChannelError.notFoundError)
    }
    return self.completionSignal.filter { $0.id == reqId }
  }
  
  private func executeFisrtInitialItemIfNeeded() {
    dispatchSyncOnBack {
      guard
        self.items.filter({ $0.status == .progress || $0.status == .completed }).count == 0,
        var item = self.items.filter({ $0.status == .initial }).first else  {
        return
      }
      item.status = .progress
      self.execute(item: item)
    }
  }

  private func findIndexOf(item: ChatQueuable) -> Int? {
    guard let index = self.items.firstIndex(where: { $0.id == item.id }) else {
      return nil
    }
    return index
  }
}
