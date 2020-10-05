/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 



/// 
/// Mark the end of a * or + loop.
/// 

final class LoopEndState: ATNState {
    var loopBackState: ATNState?

    override
    func getStateType() -> Int {
        return ATNState.LOOP_END
    }
}
