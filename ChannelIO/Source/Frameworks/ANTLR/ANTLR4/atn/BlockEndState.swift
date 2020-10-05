/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 



/// 
/// Terminal node of a simple `(a|b|c)` block.
/// 

final class BlockEndState: ATNState {
    var startState: BlockStartState?

    override
    func getStateType() -> Int {
        return ATNState.BLOCK_END
    }
}
