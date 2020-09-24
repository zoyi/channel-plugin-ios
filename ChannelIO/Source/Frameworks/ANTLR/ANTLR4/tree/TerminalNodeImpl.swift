/* Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
 * Use of this file is governed by the BSD 3-clause license that
 * can be found in the LICENSE.txt file in the project root.
 */


class TerminalNodeImpl: TerminalNode {
    var symbol: Token
    weak var parent: ParseTree?

    init(_ symbol: Token) {
        self.symbol = symbol
    }


    func getChild(_ i: Int) -> Tree? {
        return nil
    }

    subscript(index: Int) -> ParseTree {
        preconditionFailure("Index out of range (TerminalNode never has children)")
    }

    func getSymbol() -> Token? {
        return symbol
    }

    func getParent() -> Tree? {
        return parent
    }

    func setParent(_ parent: RuleContext) {
        self.parent = parent
    }

    func getPayload() -> AnyObject {
        return symbol
    }

    func getSourceInterval() -> Interval {
        //if   symbol == nil   { return Interval.INVALID; }

        let tokenIndex: Int = symbol.getTokenIndex()
        return Interval(tokenIndex, tokenIndex)
    }

    func getChildCount() -> Int {
        return 0
    }


    func accept<T>(_ visitor: ParseTreeVisitor<T>) -> T? {
        return visitor.visitTerminal(self)
    }

    func getText() -> String {
        return (symbol.getText())!
    }

    func toStringTree(_ parser: Parser) -> String {
        return description
    }

    var description: String {
        //TODO: symbol == nil?
        //if    symbol == nil   {return "<nil>"; }
        if symbol.getType() == CommonToken.EOF {
            return "<EOF>"
        }
        return symbol.getText()!
    }

    var debugDescription: String {
        return description
    }

    func toStringTree() -> String {
        return description
    }
}
