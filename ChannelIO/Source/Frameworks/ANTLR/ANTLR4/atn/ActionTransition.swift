/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 


final class ActionTransition: Transition, CustomStringConvertible {
    let ruleIndex: Int
    let actionIndex: Int
    let isCtxDependent: Bool
    // e.g., $i ref in action


    convenience init(_ target: ATNState, _ ruleIndex: Int) {
        self.init(target, ruleIndex, -1, false)
    }

    init(_ target: ATNState, _ ruleIndex: Int, _ actionIndex: Int, _ isCtxDependent: Bool) {

        self.ruleIndex = ruleIndex
        self.actionIndex = actionIndex
        self.isCtxDependent = isCtxDependent
        super.init(target)
    }

    override
    func getSerializationType() -> Int {
        return Transition.ACTION
    }

    override
    func isEpsilon() -> Bool {
        return true // we are to be ignored by analysis 'cept for predicates
    }

    override
    func matches(_ symbol: Int, _ minVocabSymbol: Int, _ maxVocabSymbol: Int) -> Bool {
        return false
    }

    var description: String {
        return "action_\(ruleIndex):\(actionIndex)"
    }

}
