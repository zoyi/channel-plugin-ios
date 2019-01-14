//
//  PushBotManager.swift
//  ChannelIO
//
//  Created by Haeun Chung on 30/11/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

class PushBotManager {
  internal static var disposeBag = DisposeBag()
  internal static var reached: [String: Bool] = [:]
  
  class func reset() {
    reached = [:]
    disposeBag = DisposeBag()
  }
  
  class func process(with nudges: [CHNudge]? = [], property: [String: Any]) {
    guard let nudges = nudges else { return }
    guard mainStore.state.channel.canUsePushBot else { return }
    let guest = mainStore.state.guest
    let filtered = nudges
      .filter({ (nudge) -> Bool in
        return userChatSelector(
          state: mainStore.state,
          userChatId: CHConstants.nudgeChat + nudge.id
        ) == nil
      })

    Observable.from(filtered)
      .toArray()
      .flatMap { Observable.from($0) }
      .flatMap ({ (nudge) -> Observable<CHNudge> in
        return Observable.just(nudge)
          .delay(
            Double(nudge.triggerDelay),
            scheduler: MainScheduler.instance
          )
      })
      .filter { reached[$0.id] == false || reached[$0.id] == nil }
      .concatMap ({ (nudge) -> Observable<NudgeReachResponse> in
        return nudge.reach()
      })
      .single { $0.reach == true }
      .filter { _ in mainStore.state.checkinState.status == .success }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (response) in
        if let nudge = response.nudge {
          reached[nudge.id] = true
        }
        
        let (chat, message, session) = CHUserChat.createLocal(
          writer: response.bot,
          variant: response.variant
        )

        mainStore.dispatch(
          CreateLocalUserChat(
            chat: chat,
            message: message,
            writer: response.bot,
            session: session
          )
        )
        guard ChannelIO.baseNavigation == nil else { return }
        if let chat = chat, let message = message {
          ChannelIO.showNotification(pushData: CHPush(
            chat: chat,
            message: message,
            response: response
          ))
        }

      }, onError: { (error) in
        //
      }).disposed(by: disposeBag)
  }
}
