/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 





final class RuleTransition: Transition {
    /// 
    /// Ptr to the rule definition object for this rule ref
    /// 
    let ruleIndex: Int
    // no Rule object at runtime

    let precedence: Int

    /// 
    /// What node to begin computations following ref to rule
    /// 
    let followState: ATNState

    init(_ ruleStart: RuleStartState,
                _ ruleIndex: Int,
                _ precedence: Int,
                _ followState: ATNState) {

        self.ruleIndex = ruleIndex
        self.precedence = precedence
        self.followState = followState

        super.init(ruleStart)
    }

    override
    func getSerializationType() -> Int {
        return Transition.RULE
    }

    override
    func isEpsilon() -> Bool {
        return true
    }

    override
    func matches(_ symbol: Int, _ minVocabSymbol: Int, _ maxVocabSymbol: Int) -> Bool {
        return false
    }
}
