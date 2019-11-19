//
//  UIView+Extensions.swift
//  ChannelIO
//
//  Created by Haeun Chung on 28/05/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

internal extension UIView {
  static func activate(constraints: [NSLayoutConstraint]) {
    constraints.forEach { ($0.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false }
    NSLayoutConstraint.activate(constraints)
  }
  
  func pin(to view: UIView, insets: UIEdgeInsets = .zero) {
    UIView.activate(constraints: [
      topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
      leftAnchor.constraint(equalTo: view.leftAnchor, constant: insets.left),
      bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
      rightAnchor.constraint(equalTo: view.rightAnchor, constant: -insets.right)
    ])
  }
  
  func center(in view: UIView, offset: UIOffset = .zero) {
    UIView.activate(constraints: [
      centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: offset.horizontal),
      centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: offset.vertical)
    ])
  }
  
  var util_safeAreaInsets: UIEdgeInsets {
    if #available(iOS 11.0, *) {
      return safeAreaInsets
    } else {
      return .zero
    }
  }
  
  var firstResponder: UIView? {
    guard !isFirstResponder else { return self }

    for subview in subviews {
      if let firstResponder = subview.firstResponder {
        return firstResponder
      }
    }

    return nil
  }
}

protocol RxGesture {
  var subscriber: AnyObserver<Any?> { get set }
}

class RxClickGesture: UITapGestureRecognizer, RxGesture {
  var subscriber: AnyObserver<Any?>

  init(container: UIView, target: AnyObserver<Any?>, action: Selector?) {
    self.subscriber = target
    super.init(target: container, action: action)
  }
}

extension UIView {
  @objc func rxOnNext(_ gesture: UIGestureRecognizer) {
    if let rxGesture = gesture as? RxGesture {
      rxGesture.subscriber.onNext(gesture)
    }
  }
  
  func rxForClick(cancelTouches: Bool = true) -> Observable<Any?> {
    self.isUserInteractionEnabled = true

    return Observable.create { [weak self] subscriber in
      let gesture = RxClickGesture(container: self!, target: subscriber, action: #selector(self!.rxOnNext(_:)))
      gesture.numberOfTapsRequired = 1
      gesture.cancelsTouchesInView = cancelTouches
      self?.addGestureRecognizer(gesture)

      return Disposables.create {
        subscriber.onCompleted()
        self?.removeGestureRecognizer(gesture)
      }
    }
  }
}

internal extension UIScrollView {
  var util_adjustedContentInset: UIEdgeInsets {
    if #available(iOS 11.0, *) {
      return adjustedContentInset
    } else {
      return contentInset
    }
  }
  
  func stopScrolling() {
    guard isDragging else { return }

    var offset = contentOffset
    offset.y -= 1
    self.setContentOffset(offset, animated: false)
    offset.y += 1
    self.setContentOffset(offset, animated: false)
  }
}


extension UIViewController {
  private static let insetBackgroundViewTag = 98721 //Cool number
  
  func paintSafeAreaBottomInset(with color: UIColor?) {
    guard #available(iOS 11.0, *) else {
      return
    }
    if let insetView = view.viewWithTag(UIViewController.insetBackgroundViewTag) {
      insetView.backgroundColor = color
      return
    }
    
    let insetView = UIView(frame: .zero)
    insetView.tag = UIViewController.insetBackgroundViewTag
    insetView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(insetView)
    view.sendSubviewToBack(insetView)
    
    insetView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    insetView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    insetView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    insetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    
    insetView.backgroundColor = color
  }
}
