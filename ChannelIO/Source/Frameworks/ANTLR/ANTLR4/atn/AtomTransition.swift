/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 


/// 
/// TODO: make all transitions sets? no, should remove set edges
/// 

final class AtomTransition: Transition, CustomStringConvertible {
    /// 
    /// The token type or character value; or, signifies special label.
    /// 
    let label: Int

    init(_ target: ATNState, _ label: Int) {

        self.label = label
        super.init(target)
    }

    override
    func getSerializationType() -> Int {
        return Transition.ATOM
    }

    override
    func labelIntervalSet() -> IntervalSet? {
        return IntervalSet(label)
    }

    override
    func matches(_ symbol: Int, _ minVocabSymbol: Int, _ maxVocabSymbol: Int) -> Bool {
        return label == symbol
    }


    var description: String {
        return String(label)
    }
}
