//
//  ChatQueueBaseItem.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/05.
//

import RxSwift

class ChatQueueBaseItem: ChatQueuable {
  private var type: String = ChatType.userChat.rawValue
  var channelId: String = ""
  var chatType: ChatType {
    set { self.type = newValue.rawValue }
    get { return ChatType(rawValue: self.type)! }
  }
  var chatId: String = ""
  var requestedAt = Date()
  var progress: Double = 0.0
  var id: String = ""
  private var internalStatus: String = ChatQueueItemStatus.initial.rawValue
  var status: ChatQueueItemStatus {
    get { return ChatQueueItemStatus(rawValue: internalStatus)! }
    set { internalStatus = newValue.rawValue }
  }

  func request() -> Observable<ChatQueuable> {
    fatalError("ChatQueueBaseItem has to be overrided")
  }
}
