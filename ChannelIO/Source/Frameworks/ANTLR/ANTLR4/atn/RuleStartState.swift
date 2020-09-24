/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 


final class RuleStartState: ATNState {
    var stopState: RuleStopState?
    var isPrecedenceRule: Bool = false
    //Synonymous with rule being left recursive; consider renaming.

    override
    func getStateType() -> Int {
        return ATNState.RULE_START
    }
}
