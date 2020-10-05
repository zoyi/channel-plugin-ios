/* Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
 * Use of this file is governed by the BSD 3-clause license that
 * can be found in the LICENSE.txt file in the project root.
 */

//
//  Stack.swift
//  antlr.swift
//
//  Created by janyou on 15/9/8.
//

import Foundation

struct Stack<T> {
    var items = [T]()
    mutating func push(_ item: T) {
        items.append(item)
    }
    @discardableResult
    mutating func pop() -> T {
        return items.removeLast()
    }

    mutating func clear() {
        return items.removeAll()
    }

    func peek() -> T? {
        return items.last
    }
    var isEmpty: Bool {
        return items.isEmpty
    }

}
