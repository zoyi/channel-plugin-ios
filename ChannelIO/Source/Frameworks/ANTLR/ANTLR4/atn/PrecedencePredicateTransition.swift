/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 



/// 
/// 
/// -  Sam Harwell
/// 

final class PrecedencePredicateTransition: AbstractPredicateTransition, CustomStringConvertible {
    let precedence: Int

    init(_ target: ATNState, _ precedence: Int) {

        self.precedence = precedence
        super.init(target)
    }

    override
    func getSerializationType() -> Int {
        return Transition.PRECEDENCE
    }

    override
    func isEpsilon() -> Bool {
        return true
    }

    override
    func matches(_ symbol: Int, _ minVocabSymbol: Int, _ maxVocabSymbol: Int) -> Bool {
        return false
    }

    func getPredicate() -> SemanticContext.PrecedencePredicate {
        return SemanticContext.PrecedencePredicate(precedence)
    }

    var description: String {
        return "\(precedence)  >= _p"
    }
}
