/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 


final class StarLoopbackState: ATNState {
    func getLoopEntryState() -> StarLoopEntryState {
        return transition(0).target as! StarLoopEntryState
    }

    override
    func getStateType() -> Int {
        return ATNState.STAR_LOOP_BACK
    }
}
