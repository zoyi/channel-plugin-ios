/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 


/// 
/// 
/// The following images show the relation of states and
/// _org.antlr.v4.runtime.atn.ATNState#transitions_ for various grammar constructs.
/// 
/// 
/// * Solid edges marked with an &#0949; indicate a required
/// _org.antlr.v4.runtime.atn.EpsilonTransition_.
/// 
/// * Dashed edges indicate locations where any transition derived from
/// _org.antlr.v4.runtime.atn.Transition_ might appear.
/// 
/// * Dashed nodes are place holders for either a sequence of linked
/// _org.antlr.v4.runtime.atn.BasicState_ states or the inclusion of a block representing a nested
/// construct in one of the forms below.
/// 
/// * Nodes showing multiple outgoing alternatives with a `...` support
/// any number of alternatives (one or more). Nodes without the `...` only
/// support the exact number of alternatives shown in the diagram.
/// 
/// 
/// ## Basic Blocks
/// 
/// ### Rule
/// 
/// 
/// 
/// ## Block of 1 or more alternatives
/// 
/// 
/// 
/// ## Greedy Loops
/// 
/// ### Greedy Closure: `(...)*`
/// 
/// 
/// 
/// ### Greedy Positive Closure: `(...)+`
/// 
/// 
/// 
/// ### Greedy Optional: `(...)?`
/// 
/// 
/// 
/// ## Non-Greedy Loops
/// 
/// ### Non-Greedy Closure: `(...)*?`
/// 
/// 
/// 
/// ### Non-Greedy Positive Closure: `(...)+?`
/// 
/// 
/// 
/// ### Non-Greedy Optional: `(...)??`
/// 
/// 
/// 
/// 
class ATNState: Hashable, CustomStringConvertible {
    // constants for serialization
    static let INVALID_TYPE: Int = 0
    static let BASIC: Int = 1
    static let RULE_START: Int = 2
    static let BLOCK_START: Int = 3
    static let PLUS_BLOCK_START: Int = 4
    static let STAR_BLOCK_START: Int = 5
    static let TOKEN_START: Int = 6
    static let RULE_STOP: Int = 7
    static let BLOCK_END: Int = 8
    static let STAR_LOOP_BACK: Int = 9
    static let STAR_LOOP_ENTRY: Int = 10
    static let PLUS_LOOP_BACK: Int = 11
    static let LOOP_END: Int = 12

    static let serializationNames: Array<String> =

    ["INVALID",
        "BASIC",
        "RULE_START",
        "BLOCK_START",
        "PLUS_BLOCK_START",
        "STAR_BLOCK_START",
        "TOKEN_START",
        "RULE_STOP",
        "BLOCK_END",
        "STAR_LOOP_BACK",
        "STAR_LOOP_ENTRY",
        "PLUS_LOOP_BACK",
        "LOOP_END"]


    static let INVALID_STATE_NUMBER: Int = -1

    /// 
    /// Which ATN are we in?
    /// 
    final var atn: ATN? = nil

    internal(set) final var stateNumber: Int = INVALID_STATE_NUMBER

    internal(set) final var ruleIndex: Int?
    // at runtime, we don't have Rule objects

    private(set) final var epsilonOnlyTransitions: Bool = false

    /// 
    /// Track the transitions emanating from this ATN state.
    /// 
    internal private(set) final var transitions = [Transition]()

    /// 
    /// Used to cache lookahead during parsing, not used during construction
    /// 
    internal(set) final var nextTokenWithinRule: IntervalSet?


    func hash(into hasher: inout Hasher) {
        hasher.combine(stateNumber)
    }

    func isNonGreedyExitState() -> Bool {
        return false
    }


    var description: String {
        //return "MyClass \(string)"
        return String(stateNumber)
    }
    final func getTransitions() -> [Transition] {
        return transitions
    }

    final func getNumberOfTransitions() -> Int {
        return transitions.count
    }

    final func addTransition(_ e: Transition) {
        if transitions.isEmpty {
            epsilonOnlyTransitions = e.isEpsilon()
        }
        else if epsilonOnlyTransitions != e.isEpsilon() {
            print("ATN state %d has both epsilon and non-epsilon transitions.\n", String(stateNumber))
            epsilonOnlyTransitions = false
        }

        var alreadyPresent = false
        for t in transitions {
            if t.target.stateNumber == e.target.stateNumber {
                if let tLabel = t.labelIntervalSet(), let eLabel = e.labelIntervalSet(), tLabel == eLabel {
//                    print("Repeated transition upon \(eLabel) from \(stateNumber)->\(t.target.stateNumber)")
                    alreadyPresent = true
                    break
                }
                else if t.isEpsilon() && e.isEpsilon() {
//                    print("Repeated epsilon transition from \(stateNumber)->\(t.target.stateNumber)")
                    alreadyPresent = true
                    break
                }
            }
        }

        if !alreadyPresent {
            transitions.append(e)
        }
    }

    final func transition(_ i: Int) -> Transition {
        return transitions[i]
    }

    final func setTransition(_ i: Int, _ e: Transition) {
        transitions[i] = e
    }

    final func removeTransition(_ index: Int) -> Transition {

        return transitions.remove(at: index)
    }

    func getStateType() -> Int {
        fatalError(#function + " must be overridden")
    }

    final func onlyHasEpsilonTransitions() -> Bool {
        return epsilonOnlyTransitions
    }

    final func setRuleIndex(_ ruleIndex: Int) {
        self.ruleIndex = ruleIndex
    }
}

func ==(lhs: ATNState, rhs: ATNState) -> Bool {
    if lhs === rhs {
        return true
    }
    // are these states same object?
    return lhs.stateNumber == rhs.stateNumber

}

