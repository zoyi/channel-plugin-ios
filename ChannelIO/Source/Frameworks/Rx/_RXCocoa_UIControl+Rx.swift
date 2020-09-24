//
//  UIControl+Rx.swift
//  RxCocoa
//
//  Created by Daniel Tartaglia on 5/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

//import RxSwift
import UIKit

extension _RXSwift_Reactive where Base: UIControl {
    
    /// Bindable sink for `enabled` property.
  var isEnabled: _RXCocoa_Binder<Bool> {
        return _RXCocoa_Binder(self.base) { control, value in
            control.isEnabled = value
        }
    }

    /// Bindable sink for `selected` property.
    var isSelected: _RXCocoa_Binder<Bool> {
        return _RXCocoa_Binder(self.base) { control, selected in
            control.isSelected = selected
        }
    }

    /// Reactive wrapper for target action pattern.
    ///
    /// - parameter controlEvents: Filter for observed event types.
    func controlEvent(_ controlEvents: UIControl.Event) -> _RXCocoa_ControlEvent<()> {
        let source: _RXSwift_Observable<Void> = _RXSwift_Observable.create { [weak control = self.base] observer in
                _RXSwift_MainScheduler.ensureRunningOnMainThread()

                guard let control = control else {
                    observer.on(.completed)
                    return _RXSwift_Disposables.create()
                }

                let controlTarget = _RXCocoa_ControlTarget(control: control, controlEvents: controlEvents) { _ in
                    observer.on(.next(()))
                }

                return _RXSwift_Disposables.create(with: controlTarget.dispose)
            }
            .takeUntil(deallocated)

        return _RXCocoa_ControlEvent(events: source)
    }

    /// Creates a `ControlProperty` that is triggered by target/action pattern value updates.
    ///
    /// - parameter controlEvents: Events that trigger value update sequence elements.
    /// - parameter getter: Property value getter.
    /// - parameter setter: Property value setter.
    func controlProperty<T>(
        editingEvents: UIControl.Event,
        getter: @escaping (Base) -> T,
        setter: @escaping (Base, T) -> Void
    ) -> _RXCocoa_ControlProperty<T> {
        let source: _RXSwift_Observable<T> = _RXSwift_Observable.create { [weak weakControl = base] observer in
                guard let control = weakControl else {
                    observer.on(.completed)
                    return _RXSwift_Disposables.create()
                }

                observer.on(.next(getter(control)))

                let controlTarget = _RXCocoa_ControlTarget(control: control, controlEvents: editingEvents) { _ in
                    if let control = weakControl {
                        observer.on(.next(getter(control)))
                    }
                }
                
                return _RXSwift_Disposables.create(with: controlTarget.dispose)
            }
            .takeUntil(deallocated)

        let bindingObserver = _RXCocoa_Binder(base, binding: setter)

        return _RXCocoa_ControlProperty<T>(values: source, valueSink: bindingObserver)
    }

    /// This is a separate method to better communicate to consumers that
    /// an `editingEvent` needs to fire for control property to be updated.
    internal func controlPropertyWithDefaultEvents<T>(
        editingEvents: UIControl.Event = [.allEditingEvents, .valueChanged],
        getter: @escaping (Base) -> T,
        setter: @escaping (Base, T) -> Void
        ) -> _RXCocoa_ControlProperty<T> {
        return controlProperty(
            editingEvents: editingEvents,
            getter: getter,
            setter: setter
        )
    }
}

#endif
