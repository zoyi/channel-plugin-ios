// Generated from TextBlockLexer.g4 by ANTLR 4.7.1

internal class TextBlockLexer: Lexer {

	internal static var _decisionToDFA: [DFA] = {
          var decisionToDFA = [DFA]()
          let length = TextBlockLexer._ATN.getNumberOfDecisions()
          for i in 0..<length {
          	    decisionToDFA.append(DFA(TextBlockLexer._ATN.getDecisionState(i)!, i))
          }
           return decisionToDFA
     }()

	internal static let _sharedContextCache = PredictionContextCache()

	internal
	static let GL=1, ESCAPED_GL=2, ESCAPED_GR=3, ESCAPED_AMP=4, WS=5, COLON=6, 
            EMOJI_CODES=7, UNICODES=8, ANY=9, TAG_GR=10, TAG_SLASH=11, TAG_EQUALS=12, 
            BOLD=13, ITALIC=14, LINK=15, VARIABLE=16, TAG_WS=17, ATTR_NAME=18, 
            ATTR_VALUE=19, ATTR_WS=20

	internal
	static let TAG=1, ATTRVALUE=2
	internal
	static let channelNames: [String] = [
		"DEFAULT_TOKEN_CHANNEL", "HIDDEN"
	]

	internal
	static let modeNames: [String] = [
		"DEFAULT_MODE", "TAG", "ATTRVALUE"
	]

	internal
	static let ruleNames: [String] = [
		"GL", "ESCAPED_GL", "ESCAPED_GR", "ESCAPED_AMP", "WS", "COLON", "EMOJI_CODES", 
		"UNICODES", "ANY", "TAG_GR", "TAG_SLASH", "TAG_EQUALS", "BOLD", "ITALIC", 
		"LINK", "VARIABLE", "TAG_WS", "ATTR_NAME", "ATTR_VALUE", "ATTR_WS", "DOUBLE_QUOTE_STRING", 
		"SINGLE_QUOTE_STRING", "Ws", "A", "B", "C", "D", "E", "F", "G", "H", "I", 
		"J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", 
		"X", "Y", "Z"
	]

	private static let _LITERAL_NAMES: [String?] = [
		nil, "'<'", "'&lt;'", "'&gt;'", "'&amp;'", nil, "':'", nil, nil, nil, 
		"'>'", "'/'", "'='"
	]
	private static let _SYMBOLIC_NAMES: [String?] = [
		nil, "GL", "ESCAPED_GL", "ESCAPED_GR", "ESCAPED_AMP", "WS", "COLON", "EMOJI_CODES", 
		"UNICODES", "ANY", "TAG_GR", "TAG_SLASH", "TAG_EQUALS", "BOLD", "ITALIC", 
		"LINK", "VARIABLE", "TAG_WS", "ATTR_NAME", "ATTR_VALUE", "ATTR_WS"
	]
	internal
	static let VOCABULARY = Vocabulary(_LITERAL_NAMES, _SYMBOLIC_NAMES)


	override internal
	func getVocabulary() -> Vocabulary {
		return TextBlockLexer.VOCABULARY
	}

	internal
	required init(_ input: CharStream) {
	    RuntimeMetaData.checkVersion("4.7.1", RuntimeMetaData.VERSION)
		super.init(input)
		_interp = LexerATNSimulator(self, TextBlockLexer._ATN, TextBlockLexer._decisionToDFA, TextBlockLexer._sharedContextCache)
	}

	override internal
	func getGrammarFileName() -> String { return "TextBlockLexer.g4" }

	override internal
	func getRuleNames() -> [String] { return TextBlockLexer.ruleNames }

	override internal
	func getSerializedATN() -> String { return TextBlockLexer._serializedATN }

	override internal
	func getChannelNames() -> [String] { return TextBlockLexer.channelNames }

	override internal
	func getModeNames() -> [String] { return TextBlockLexer.modeNames }

	override internal
	func getATN() -> ATN { return TextBlockLexer._ATN }


	internal
	static let _serializedATN: String = TextBlockLexerATN().jsonString

	internal
	static let _ATN: ATN = ATNDeserializer().deserializeFromJson(_serializedATN)
}
