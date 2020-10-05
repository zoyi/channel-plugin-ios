/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 


/// 
/// Implements the `type` lexer action by calling _org.antlr.v4.runtime.Lexer#setType_
/// with the assigned type.
/// 
/// -  Sam Harwell
/// -  4.2
/// 

class LexerTypeAction: LexerAction, CustomStringConvertible {
    fileprivate let type: Int

    /// 
    /// Constructs a new `type` action with the specified token type value.
    /// - parameter type: The type to assign to the token using _org.antlr.v4.runtime.Lexer#setType_.
    /// 
    init(_ type: Int) {
        self.type = type
    }

    /// 
    /// Gets the type to assign to a token created by the lexer.
    /// - returns: The type to assign to a token created by the lexer.
    /// 
    func getType() -> Int {
        return type
    }

    /// 
    /// 
    /// - returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#TYPE_.
    /// 

    override func getActionType() -> LexerActionType {
        return LexerActionType.type
    }

    /// 
    /// 
    /// - returns: This method returns `false`.
    /// 
    override
    func isPositionDependent() -> Bool {
        return false
    }

    /// 
    /// 
    /// 
    /// This action is implemented by calling _org.antlr.v4.runtime.Lexer#setType_ with the
    /// value provided by _#getType_.
    /// 

    override func execute(_ lexer: Lexer) {
        lexer.setType(type)
    }


    override func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }

    var description: String {
        return "type(\(type))"
    }
}

func ==(lhs: LexerTypeAction, rhs: LexerTypeAction) -> Bool {
    if lhs === rhs {
        return true
    }
    return lhs.type == rhs.type
}
