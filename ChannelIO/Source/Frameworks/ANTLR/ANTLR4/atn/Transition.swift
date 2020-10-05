/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 


/// 
/// An ATN transition between any two ATN states.  Subclasses define
/// atom, set, epsilon, action, predicate, rule transitions.
/// 
/// This is a one way link.  It emanates from a state (usually via a list of
/// transitions) and has a target state.
/// 
/// Since we never have to change the ATN transitions once we construct it,
/// we can fix these transitions as specific classes. The DFA transitions
/// on the other hand need to update the labels as it adds transitions to
/// the states. We'll use the term Edge for the DFA to distinguish them from
/// ATN transitions.
/// 

import Foundation

class Transition {
    // constants for serialization
    static let EPSILON: Int = 1
    static let RANGE: Int = 2
    static let RULE: Int = 3
    static let PREDICATE: Int = 4
    // e.g., {isType(input.LT(1))}?
    static let ATOM: Int = 5
    static let ACTION: Int = 6
    static let SET: Int = 7
    // ~(A|B) or ~atom, wildcard, which convert to next 2
    static let NOT_SET: Int = 8
    static let WILDCARD: Int = 9
    static let PRECEDENCE: Int = 10


    let serializationNames: Array<String> =

    ["INVALID",
     "EPSILON",
     "RANGE",
     "RULE",
     "PREDICATE",
     "ATOM",
     "ACTION",
     "SET",
     "NOT_SET",
     "WILDCARD",
     "PRECEDENCE"]


    static let serializationTypes: Dictionary<String, Int> = [

            String(describing: EpsilonTransition.self): EPSILON,
            String(describing: RangeTransition.self): RANGE,
            String(describing: RuleTransition.self): RULE,
            String(describing: PredicateTransition.self): PREDICATE,
            String(describing: AtomTransition.self): ATOM,
            String(describing: ActionTransition.self): ACTION,
            String(describing: SetTransition.self): SET,
            String(describing: NotSetTransition.self): NOT_SET,
            String(describing: WildcardTransition.self): WILDCARD,
            String(describing: PrecedencePredicateTransition.self): PRECEDENCE,


    ]


    /// 
    /// The target of this transition.
    /// 

  final var target: ATNState

    init(_ target: ATNState) {


        self.target = target
    }

    func getSerializationType() -> Int {
        fatalError(#function + " must be overridden")
    }

    /// 
    /// Determines if the transition is an "epsilon" transition.
    /// 
    /// The default implementation returns `false`.
    /// 
    /// - returns: `true` if traversing this transition in the ATN does not
    /// consume an input symbol; otherwise, `false` if traversing this
    /// transition consumes (matches) an input symbol.
    /// 
    func isEpsilon() -> Bool {
        return false
    }


    func labelIntervalSet() -> IntervalSet? {
        return nil
    }

    func matches(_ symbol: Int, _ minVocabSymbol: Int, _ maxVocabSymbol: Int) -> Bool {
        fatalError(#function + " must be overridden")
    }
}
