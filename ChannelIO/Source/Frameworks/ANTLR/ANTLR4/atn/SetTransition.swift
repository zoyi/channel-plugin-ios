/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 



/// 
/// A transition containing a set of values.
/// 

class SetTransition: Transition, CustomStringConvertible {
    let set: IntervalSet

    // TODO (sam): should we really allow null here?
    init(_ target: ATNState, _ set: IntervalSet) {

        self.set = set
        super.init(target)
    }

    override
    func getSerializationType() -> Int {
        return Transition.SET
    }

    override
    func labelIntervalSet() -> IntervalSet? {
        return set
    }

    override
    func matches(_ symbol: Int, _ minVocabSymbol: Int, _ maxVocabSymbol: Int) -> Bool {
        return set.contains(symbol)
    }

    var description: String {
        return set.description
    }


}
