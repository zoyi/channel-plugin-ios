/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 


class EmptyPredictionContext: SingletonPredictionContext {
    init() {
        super.init(nil, PredictionContext.EMPTY_RETURN_STATE)
    }

    override
    func isEmpty() -> Bool {
        return true
    }

    override
    func size() -> Int {
        return 1
    }

    override
    func getParent(_ index: Int) -> PredictionContext? {
        return nil
    }

    override
    func getReturnState(_ index: Int) -> Int {
        return returnState
    }


    override
    var description: String {
        return "$"
    }
}


func ==(lhs: EmptyPredictionContext, rhs: EmptyPredictionContext) -> Bool {
    if lhs === rhs {
        return true
    }

    return false
}
