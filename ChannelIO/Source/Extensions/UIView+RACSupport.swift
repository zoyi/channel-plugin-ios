//
//  UIView+RACSupport.swift
//  CHPlugin
//
//  Created by Haeun Chung on 08/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

//import RxSwift
import UIKit

class ClickGesture : UITapGestureRecognizer {
  var subscriber: _RXSwift_AnyObserver<Any?>
  init(container: UIView, target: Any, action: Selector?) {
    self.subscriber = target as! _RXSwift_AnyObserver<Any?>
    super.init(target: container, action: action)
  }
}

extension UIView {
  func signalForClick() -> _RXSwift_Observable<Any?> {
    self.isUserInteractionEnabled = true

    return _RXSwift_Observable.create { [weak self] subscriber in
      let gesture = ClickGesture(container: self!, target:subscriber, action:#selector(self!.onNext(_:)))
      gesture.numberOfTapsRequired = 1
      gesture.cancelsTouchesInView = true

      self?.gestureRecognizers = self?.gestureRecognizers?.filter{ !$0.isKind(of: ClickGesture.self) }
      self?.addGestureRecognizer(gesture)
      
      return _RXSwift_Disposables.create() {
        subscriber.onCompleted()
        self?.removeGestureRecognizer(gesture)
      }
    }
  }
  
  @objc func onNext(_ gesture: ClickGesture) {
    gesture.subscriber.onNext(nil)
  }
}
