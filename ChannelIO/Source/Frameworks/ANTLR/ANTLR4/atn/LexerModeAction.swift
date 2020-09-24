/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 



/// 
/// Implements the `mode` lexer action by calling _org.antlr.v4.runtime.Lexer#mode_ with
/// the assigned mode.
/// 
/// -  Sam Harwell
/// -  4.2
/// 

final class LexerModeAction: LexerAction, CustomStringConvertible {
    fileprivate let mode: Int

    /// 
    /// Constructs a new `mode` action with the specified mode value.
    /// - parameter mode: The mode value to pass to _org.antlr.v4.runtime.Lexer#mode_.
    /// 
    init(_ mode: Int) {
        self.mode = mode
    }

    /// 
    /// Get the lexer mode this action should transition the lexer to.
    /// 
    /// - returns: The lexer mode for this `mode` command.
    /// 
    func getMode() -> Int {
        return mode
    }

    /// 
    /// 
    /// - returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#MODE_.
    /// 

    override func getActionType() -> LexerActionType {
        return LexerActionType.mode
    }

    /// 
    /// 
    /// - returns: This method returns `false`.
    /// 

    override func isPositionDependent() -> Bool {
        return false
    }

    /// 
    /// 
    /// 
    /// This action is implemented by calling _org.antlr.v4.runtime.Lexer#mode_ with the
    /// value provided by _#getMode_.
    /// 
    override
    func execute(_ lexer: Lexer) {
        lexer.mode(mode)
    }

    override func hash(into hasher: inout Hasher) {
        hasher.combine(mode)
    }

    var description: String {
        return "mode(\(mode))"
    }
}

func ==(lhs: LexerModeAction, rhs: LexerModeAction) -> Bool {
    if lhs === rhs {
        return true
    }

    return lhs.mode == rhs.mode
}
