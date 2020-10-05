/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 

//
//  TokenExtension.swift
//  Antlr.swift
//
//  Created by janyou on 15/9/4.
//

import Foundation

extension Token {

    static var INVALID_TYPE: Int {
        return 0
    }

    /// 
    /// During lookahead operations, this "token" signifies we hit rule end ATN state
    /// and did not follow it despite needing to.
    /// 
    static var EPSILON: Int {
        return -2
    }


    static var MIN_USER_TOKEN_TYPE: Int {
        return 1
    }

    static var EOF: Int {
        return -1
    }
    
    ///
    /// All tokens go to the parser (unless skip() is called in that rule)
    /// on a particular "channel".  The parser tunes to a particular channel
    /// so that whitespace etc... can go to the parser on a "hidden" channel.
    ///
    static var DEFAULT_CHANNEL: Int {
        return 0
    }
    
    /// 
    /// Anything on different channel than DEFAULT_CHANNEL is not parsed
    /// by parser.
    ///
    static var HIDDEN_CHANNEL: Int {
        return 1
    }
    
    /// 
    /// This is the minimum constant value which can be assigned to a
    /// user-defined token channel.
    /// 
    /// 
    /// The non-negative numbers less than _#MIN_USER_CHANNEL_VALUE_ are
    /// assigned to the predefined channels _#DEFAULT_CHANNEL_ and
    /// _#HIDDEN_CHANNEL_.
    /// 
    /// - seealso: org.antlr.v4.runtime.Token#getChannel()
    /// 
    static var MIN_USER_CHANNEL_VALUE: Int {
        return 2
    }
}
