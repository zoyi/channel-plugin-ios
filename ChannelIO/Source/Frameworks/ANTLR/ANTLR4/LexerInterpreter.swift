/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 


class LexerInterpreter: Lexer {
    internal let grammarFileName: String
    internal let atn: ATN

    internal let ruleNames: [String]
    internal let channelNames: [String]
    internal let modeNames: [String]

    private let vocabulary: Vocabulary?

    internal final var _decisionToDFA: [DFA]
    internal let _sharedContextCache = PredictionContextCache()

    init(_ grammarFileName: String, _ vocabulary: Vocabulary, _ ruleNames: Array<String>, _ channelNames: Array<String>, _ modeNames: Array<String>, _ atn: ATN, _ input: CharStream) throws {

        self.grammarFileName = grammarFileName
        self.atn = atn
        self.ruleNames = ruleNames
        self.channelNames = channelNames
        self.modeNames = modeNames
        self.vocabulary = vocabulary

        self._decisionToDFA = [DFA]()
        for i in 0 ..< atn.getNumberOfDecisions() {
            _decisionToDFA[i] = DFA(atn.getDecisionState(i)!, i)
        }
        super.init(input)
        self._interp = LexerATNSimulator(self, atn, _decisionToDFA, _sharedContextCache)

        if atn.grammarType != ATNType.lexer {
            throw ANTLRError.illegalArgument(msg: "The ATN must be a lexer ATN.")

        }
    }

    required init(_ input: CharStream) {
        fatalError("Use the other initializer")
    }

    override
    func getATN() -> ATN {
        return atn
    }

    override
    func getGrammarFileName() -> String {
        return grammarFileName
    }

    override
    func getRuleNames() -> [String] {
        return ruleNames
    }

    override
    func getChannelNames() -> [String] {
        return channelNames
    }

    override
    func getModeNames() -> [String] {
        return modeNames
    }

    override
    func getVocabulary() -> Vocabulary {
        if vocabulary != nil {
            return vocabulary!
        }

        return super.getVocabulary()
    }
}
