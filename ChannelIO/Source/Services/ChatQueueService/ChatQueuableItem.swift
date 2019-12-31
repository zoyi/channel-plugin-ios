//
//  ChatQueuableItem.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/05.
//

import RxSwift

enum ChatQueueItemStatus: String {
  case initial
  case progress
  case completed
  case error
}

protocol ChatQueuable {
  var chatType: ChatType { get set  }
  var chatId: String { get set }
  var id: String { get set }
  var requestedAt: Date { get set }
  var progress: Double { get set }
  var status: ChatQueueItemStatus { get set }

  func request() -> Observable<ChatQueuable>
}
