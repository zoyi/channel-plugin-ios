//
//  ignore.swift
//  RxSwiftExt
//
//  Created by Florent Pillet on 10/04/16.
//  Copyright © 2016 RxSwift Community. All rights reserved.
//

import Foundation
//import RxSwift

extension _RXSwift_ObservableType where Element: Equatable {
	func ignore(_ valuesToIgnore: Element...) -> _RXSwift_Observable<Element> {
        return self.asObservable().filter { !valuesToIgnore.contains($0) }
    }

	func ignore<Sequence: Swift.Sequence>(_ valuesToIgnore: Sequence) -> _RXSwift_Observable<Element> where Sequence.Element == Element {
		return self.asObservable().filter { !valuesToIgnore.contains($0) }
	}
}
