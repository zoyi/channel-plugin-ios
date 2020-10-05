/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 


final class WildcardTransition: Transition, CustomStringConvertible {
    override init(_ target: ATNState) {
        super.init(target)
    }

    override
    func getSerializationType() -> Int {
        return Transition.WILDCARD
    }

    override
    func matches(_ symbol: Int, _ minVocabSymbol: Int, _ maxVocabSymbol: Int) -> Bool {
        return symbol >= minVocabSymbol && symbol <= maxVocabSymbol
    }

    var description: String {

        return "."
    }


}
