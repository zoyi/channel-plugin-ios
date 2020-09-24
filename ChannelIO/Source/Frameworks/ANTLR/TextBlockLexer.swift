// Generated from TextBlockLexer.g4 by ANTLR 4.7.1

class TextBlockLexer: Lexer {
	internal static var _decisionToDFA: [DFA] = {
          var decisionToDFA = [DFA]()
          let length = TextBlockLexer._ATN.getNumberOfDecisions()
          for i in 0..<length {
          	    decisionToDFA.append(DFA(TextBlockLexer._ATN.getDecisionState(i)!, i))
          }
           return decisionToDFA
     }()

	internal static let _sharedContextCache = PredictionContextCache()

	public
	static let LT = 1, VAR_BEG = 2, ESCAPED = 3, EMOJI = 4, CHAR = 5, WS = 6, ANY = 7, GT = 8,
            SLASH = 9, EQUALS = 10, TAG_NAME = 11, STR_BEG = 12, TAG_WS = 13, STR_END = 14,
            STR_ESCAPED = 15, STR_VAR_BEG = 16, STR_CHAR = 17, STR_WS = 18, STR_ANY = 19,
            VAR_END = 20, VAR_ESCAPED = 21, VAR_NAME = 22, VAR_BAR = 23, VAR_UNI = 24,
            VAR_WS = 25, VAR_ANY = 26

	public
	static let TAG = 1, STR = 2, VAR = 3
	public
	static let channelNames: [String] = [
		"DEFAULT_TOKEN_CHANNEL", "HIDDEN"
	]

	public
	static let modeNames: [String] = [
		"DEFAULT_MODE", "TAG", "STR", "VAR"
	]

	public
	static let ruleNames: [String] = [
		"LT", "VAR_BEG", "ESCAPED", "EMOJI", "CHAR", "WS", "ANY", "GT", "SLASH",
		"EQUALS", "TAG_NAME", "STR_BEG", "TAG_WS", "STR_END", "STR_ESCAPED", "STR_VAR_BEG",
		"STR_CHAR", "STR_WS", "STR_ANY", "VAR_END", "VAR_ESCAPED", "VAR_NAME",
		"VAR_BAR", "VAR_UNI", "VAR_WS", "VAR_ANY", "Ws", "Escaped"
	]

	private static let _LITERAL_NAMES: [String?] = [
		nil, "'<'", nil, nil, nil, nil, nil, nil, "'>'", "'/'", "'='", nil, nil,
		nil, nil, nil, nil, nil, nil, nil, "'}'", nil, nil, "'|'"
	]
	private static let _SYMBOLIC_NAMES: [String?] = [
		nil, "LT", "VAR_BEG", "ESCAPED", "EMOJI", "CHAR", "WS", "ANY", "GT", "SLASH",
		"EQUALS", "TAG_NAME", "STR_BEG", "TAG_WS", "STR_END", "STR_ESCAPED", "STR_VAR_BEG",
		"STR_CHAR", "STR_WS", "STR_ANY", "VAR_END", "VAR_ESCAPED", "VAR_NAME",
		"VAR_BAR", "VAR_UNI", "VAR_WS", "VAR_ANY"
	]
	public
	static let VOCABULARY = Vocabulary(_LITERAL_NAMES, _SYMBOLIC_NAMES)

	override open
	func getVocabulary() -> Vocabulary {
		return TextBlockLexer.VOCABULARY
	}

	public
	required init(_ input: CharStream) {
	    RuntimeMetaData.checkVersion("4.7.1", RuntimeMetaData.VERSION)
		super.init(input)
		_interp = LexerATNSimulator(self, TextBlockLexer._ATN, TextBlockLexer._decisionToDFA, TextBlockLexer._sharedContextCache)
	}

	override open
	func getGrammarFileName() -> String { return "TextBlockLexer.g4" }

	override open
	func getRuleNames() -> [String] { return TextBlockLexer.ruleNames }

	override open
	func getSerializedATN() -> String { return TextBlockLexer._serializedATN }

	override open
	func getChannelNames() -> [String] { return TextBlockLexer.channelNames }

	override open
	func getModeNames() -> [String] { return TextBlockLexer.modeNames }

	override open
	func getATN() -> ATN { return TextBlockLexer._ATN }

	public
	static let _serializedATN: String = TextBlockLexerATN().jsonString

	public
	static let _ATN: ATN = ATNDeserializer().deserializeFromJson(_serializedATN)
}
