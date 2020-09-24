// Generated from TextBlockParser.g4 by ANTLR 4.7.1

class TextBlockParser: Parser {
	internal static var _decisionToDFA: [DFA] = {
          var decisionToDFA = [DFA]()
          let length = TextBlockParser._ATN.getNumberOfDecisions()
          for i in 0..<length {
            decisionToDFA.append(DFA(TextBlockParser._ATN.getDecisionState(i)!, i))
           }
           return decisionToDFA
     }()

	internal static let _sharedContextCache = PredictionContextCache()

	public
	enum Tokens: Int {
		case EOF = -1, LT = 1, VAR_BEG = 2, ESCAPED = 3, EMOJI = 4, CHAR = 5,
                 WS = 6, ANY = 7, GT = 8, SLASH = 9, EQUALS = 10, TAG_NAME = 11,
                 STR_BEG = 12, TAG_WS = 13, STR_END = 14, STR_ESCAPED = 15,
                 STR_VAR_BEG = 16, STR_CHAR = 17, STR_WS = 18, STR_ANY = 19,
                 VAR_END = 20, VAR_ESCAPED = 21, VAR_NAME = 22, VAR_BAR = 23,
                 VAR_UNI = 24, VAR_WS = 25, VAR_ANY = 26
	}

	public
	static let RULE_block = 0, RULE_tag = 1, RULE_attribute = 2, RULE_attrValue = 3,
            RULE_content = 4, RULE_emoji = 5, RULE_variable = 6, RULE_variableFallback = 7,
            RULE_plain = 8, RULE_escape = 9

	public
	static let ruleNames: [String] = [
		"block", "tag", "attribute", "attrValue", "content", "emoji", "variable",
		"variableFallback", "plain", "escape"
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
	func getGrammarFileName() -> String { return "TextBlockParser.g4" }

	override open
	func getRuleNames() -> [String] { return TextBlockParser.ruleNames }

	override open
	func getSerializedATN() -> String { return TextBlockParser._serializedATN }

	override open
	func getATN() -> ATN { return TextBlockParser._ATN }

	override open
	func getVocabulary() -> Vocabulary {
	    return TextBlockParser.VOCABULARY
	}

	override public
	init(_ input: TokenStream) throws {
	    RuntimeMetaData.checkVersion("4.7.1", RuntimeMetaData.VERSION)
		try super.init(input)
		_interp = ParserATNSimulator(self, TextBlockParser._ATN, TextBlockParser._decisionToDFA, TextBlockParser._sharedContextCache)
	}

	class BlockContext: ParserRuleContext {
			open
			func EOF() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.EOF.rawValue, 0)
			}
			open
			func tag() -> [TagContext] {
				return getRuleContexts(TagContext.self)
			}
			open
			func tag(_ i: Int) -> TagContext? {
				return getRuleContext(TagContext.self, i)
			}
			open
			func content() -> [ContentContext] {
				return getRuleContexts(ContentContext.self)
			}
			open
			func content(_ i: Int) -> ContentContext? {
				return getRuleContext(ContentContext.self, i)
			}
		override open
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_block
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterBlock(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitBlock(self)
			}
		}
	}
	@discardableResult
	 func block() throws -> BlockContext {
		var _localctx = BlockContext(_ctx, getState())
		try enterRule(_localctx, 0, TextBlockParser.RULE_block)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(24)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (//closure
		 	 { () -> Bool in
		 	      let testSet: Bool = {  () -> Bool in
		 	   let testArray: [Int] = [_la, TextBlockParser.Tokens.LT.rawValue, TextBlockParser.Tokens.VAR_BEG.rawValue, TextBlockParser.Tokens.ESCAPED.rawValue, TextBlockParser.Tokens.EMOJI.rawValue, TextBlockParser.Tokens.CHAR.rawValue, TextBlockParser.Tokens.WS.rawValue, TextBlockParser.Tokens.ANY.rawValue, TextBlockParser.Tokens.STR_ESCAPED.rawValue, TextBlockParser.Tokens.STR_VAR_BEG.rawValue, TextBlockParser.Tokens.VAR_ESCAPED.rawValue]
		 	    return  Utils.testBitLeftShiftArray(testArray, 0)
		 	}()
		 	      return testSet
		 	 }()) {
		 		setState(22)
		 		try _errHandler.sync(self)
		 		switch (TextBlockParser.Tokens(rawValue: try _input.LA(1))!) {
		 		case .LT:
		 			setState(20)
		 			try tag()

		 			break
		 		case .VAR_BEG:fallthrough
		 		case .ESCAPED:fallthrough
		 		case .EMOJI:fallthrough
		 		case .CHAR:fallthrough
		 		case .WS:fallthrough
		 		case .ANY:fallthrough
		 		case .STR_ESCAPED:fallthrough
		 		case .STR_VAR_BEG:fallthrough
		 		case .VAR_ESCAPED:
		 			setState(21)
		 			try content()

		 			break
		 		default:
		 			throw ANTLRException.recognition(e: NoViableAltException(self))
		 		}

		 		setState(26)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 	}
		 	setState(27)
		 	try match(TextBlockParser.Tokens.EOF.rawValue)
		} catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	class TagContext: ParserRuleContext {
			open
			func LT() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.LT.rawValue)
			}
			open
			func LT(_ i: Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.LT.rawValue, i)
			}
			open
			func TAG_NAME() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.TAG_NAME.rawValue)
			}
			open
			func TAG_NAME(_ i: Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.TAG_NAME.rawValue, i)
			}
			open
			func GT() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.GT.rawValue)
			}
			open
			func GT(_ i: Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.GT.rawValue, i)
			}
			open
			func SLASH() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.SLASH.rawValue, 0)
			}
			open
			func attribute() -> [AttributeContext] {
				return getRuleContexts(AttributeContext.self)
			}
			open
			func attribute(_ i: Int) -> AttributeContext? {
				return getRuleContext(AttributeContext.self, i)
			}
			open
			func tag() -> [TagContext] {
				return getRuleContexts(TagContext.self)
			}
			open
			func tag(_ i: Int) -> TagContext? {
				return getRuleContext(TagContext.self, i)
			}
			open
			func content() -> [ContentContext] {
				return getRuleContexts(ContentContext.self)
			}
			open
			func content(_ i: Int) -> ContentContext? {
				return getRuleContext(ContentContext.self, i)
			}
		override open
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_tag
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterTag(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitTag(self)
			}
		}
	}
	@discardableResult
	 func tag() throws -> TagContext {
		var _localctx = TagContext(_ctx, getState())
		try enterRule(_localctx, 2, TextBlockParser.RULE_tag)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
			var _alt: Int
		 	try enterOuterAlt(_localctx, 1)
		 	setState(29)
		 	try match(TextBlockParser.Tokens.LT.rawValue)
		 	setState(30)
		 	try match(TextBlockParser.Tokens.TAG_NAME.rawValue)
		 	setState(34)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (//closure
		 	 { () -> Bool in
		 	      let testSet: Bool = _la == TextBlockParser.Tokens.TAG_NAME.rawValue
		 	      return testSet
		 	 }()) {
		 		setState(31)
		 		try attribute()

		 		setState(36)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 	}
		 	setState(37)
		 	try match(TextBlockParser.Tokens.GT.rawValue)
		 	setState(42)
		 	try _errHandler.sync(self)
		 	_alt = try getInterpreter().adaptivePredict(_input, 4, _ctx)
		 	while (_alt != 2 && _alt != ATN.INVALID_ALT_NUMBER) {
		 		if ( _alt == 1 ) {
		 			setState(40)
		 			try _errHandler.sync(self)
		 			switch (TextBlockParser.Tokens(rawValue: try _input.LA(1))!) {
		 			case .LT:
		 				setState(38)
		 				try tag()

		 				break
		 			case .VAR_BEG:fallthrough
		 			case .ESCAPED:fallthrough
		 			case .EMOJI:fallthrough
		 			case .CHAR:fallthrough
		 			case .WS:fallthrough
		 			case .ANY:fallthrough
		 			case .STR_ESCAPED:fallthrough
		 			case .STR_VAR_BEG:fallthrough
		 			case .VAR_ESCAPED:
		 				setState(39)
		 				try content()

		 				break
		 			default:
		 				throw ANTLRException.recognition(e: NoViableAltException(self))
		 			}
		 		}
		 		setState(44)
		 		try _errHandler.sync(self)
		 		_alt = try getInterpreter().adaptivePredict(_input, 4, _ctx)
		 	}
		 	setState(45)
		 	try match(TextBlockParser.Tokens.LT.rawValue)
		 	setState(46)
		 	try match(TextBlockParser.Tokens.SLASH.rawValue)
		 	setState(47)
		 	try match(TextBlockParser.Tokens.TAG_NAME.rawValue)
		 	setState(48)
		 	try match(TextBlockParser.Tokens.GT.rawValue)
		} catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	class AttributeContext: ParserRuleContext {
			open
			func TAG_NAME() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.TAG_NAME.rawValue, 0)
			}
			open
			func EQUALS() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.EQUALS.rawValue, 0)
			}
			open
			func STR_BEG() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.STR_BEG.rawValue, 0)
			}
			open
			func attrValue() -> AttrValueContext? {
				return getRuleContext(AttrValueContext.self, 0)
			}
			open
			func STR_END() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.STR_END.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_attribute
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterAttribute(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitAttribute(self)
			}
		}
	}
	@discardableResult
	 func attribute() throws -> AttributeContext {
		var _localctx = AttributeContext(_ctx, getState())
		try enterRule(_localctx, 4, TextBlockParser.RULE_attribute)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(50)
		 	try match(TextBlockParser.Tokens.TAG_NAME.rawValue)
		 	setState(51)
		 	try match(TextBlockParser.Tokens.EQUALS.rawValue)
		 	setState(52)
		 	try match(TextBlockParser.Tokens.STR_BEG.rawValue)
		 	setState(53)
		 	try attrValue()
		 	setState(54)
		 	try match(TextBlockParser.Tokens.STR_END.rawValue)
		} catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	class AttrValueContext: ParserRuleContext {
			open
			func escape() -> [EscapeContext] {
				return getRuleContexts(EscapeContext.self)
			}
			open
			func escape(_ i: Int) -> EscapeContext? {
				return getRuleContext(EscapeContext.self, i)
			}
			open
			func variable() -> [VariableContext] {
				return getRuleContexts(VariableContext.self)
			}
			open
			func variable(_ i: Int) -> VariableContext? {
				return getRuleContext(VariableContext.self, i)
			}
			open
			func STR_CHAR() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.STR_CHAR.rawValue)
			}
			open
			func STR_CHAR(_ i: Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.STR_CHAR.rawValue, i)
			}
			open
			func STR_ANY() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.STR_ANY.rawValue)
			}
			open
			func STR_ANY(_ i: Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.STR_ANY.rawValue, i)
			}
			open
			func STR_WS() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.STR_WS.rawValue)
			}
			open
			func STR_WS(_ i: Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.STR_WS.rawValue, i)
			}
		override open
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_attrValue
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterAttrValue(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitAttrValue(self)
			}
		}
	}
	@discardableResult
	 func attrValue() throws -> AttrValueContext {
		var _localctx = AttrValueContext(_ctx, getState())
		try enterRule(_localctx, 6, TextBlockParser.RULE_attrValue)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(61)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	repeat {
		 		setState(61)
		 		try _errHandler.sync(self)
		 		switch (TextBlockParser.Tokens(rawValue: try _input.LA(1))!) {
		 		case .ESCAPED:fallthrough
		 		case .STR_ESCAPED:fallthrough
		 		case .VAR_ESCAPED:
		 			setState(56)
		 			try escape()

		 			break
		 		case .VAR_BEG:fallthrough
		 		case .STR_VAR_BEG:
		 			setState(57)
		 			try variable()

		 			break

		 		case .STR_CHAR:
		 			setState(58)
		 			try match(TextBlockParser.Tokens.STR_CHAR.rawValue)

		 			break

		 		case .STR_ANY:
		 			setState(59)
		 			try match(TextBlockParser.Tokens.STR_ANY.rawValue)

		 			break

		 		case .STR_WS:
		 			setState(60)
		 			try match(TextBlockParser.Tokens.STR_WS.rawValue)

		 			break
		 		default:
		 			throw ANTLRException.recognition(e: NoViableAltException(self))
		 		}

		 		setState(63)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 	} while (//closure
		 	 { () -> Bool in
		 	      let testSet: Bool = {  () -> Bool in
		 	   let testArray: [Int] = [_la, TextBlockParser.Tokens.VAR_BEG.rawValue, TextBlockParser.Tokens.ESCAPED.rawValue, TextBlockParser.Tokens.STR_ESCAPED.rawValue, TextBlockParser.Tokens.STR_VAR_BEG.rawValue, TextBlockParser.Tokens.STR_CHAR.rawValue, TextBlockParser.Tokens.STR_WS.rawValue, TextBlockParser.Tokens.STR_ANY.rawValue, TextBlockParser.Tokens.VAR_ESCAPED.rawValue]
		 	    return  Utils.testBitLeftShiftArray(testArray, 0)
		 	}()
		 	      return testSet
		 	 }())
		} catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	class ContentContext: ParserRuleContext {
			open
			func escape() -> [EscapeContext] {
				return getRuleContexts(EscapeContext.self)
			}
			open
			func escape(_ i: Int) -> EscapeContext? {
				return getRuleContext(EscapeContext.self, i)
			}
			open
			func emoji() -> [EmojiContext] {
				return getRuleContexts(EmojiContext.self)
			}
			open
			func emoji(_ i: Int) -> EmojiContext? {
				return getRuleContext(EmojiContext.self, i)
			}
			open
			func variable() -> [VariableContext] {
				return getRuleContexts(VariableContext.self)
			}
			open
			func variable(_ i: Int) -> VariableContext? {
				return getRuleContext(VariableContext.self, i)
			}
			open
			func plain() -> [PlainContext] {
				return getRuleContexts(PlainContext.self)
			}
			open
			func plain(_ i: Int) -> PlainContext? {
				return getRuleContext(PlainContext.self, i)
			}
		override open
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_content
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterContent(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitContent(self)
			}
		}
	}
	@discardableResult
	 func content() throws -> ContentContext {
		var _localctx = ContentContext(_ctx, getState())
		try enterRule(_localctx, 8, TextBlockParser.RULE_content)
		defer {
	    		try! exitRule()
	    }
		do {
			var _alt: Int
		 	try enterOuterAlt(_localctx, 1)
		 	setState(69)
		 	try _errHandler.sync(self)
		 	_alt = 1
		 	repeat {
		 		switch (_alt) {
		 		case 1:
		 			setState(69)
		 			try _errHandler.sync(self)
		 			switch (TextBlockParser.Tokens(rawValue: try _input.LA(1))!) {
		 			case .ESCAPED:fallthrough
		 			case .STR_ESCAPED:fallthrough
		 			case .VAR_ESCAPED:
		 				setState(65)
		 				try escape()

		 				break

		 			case .EMOJI:
		 				setState(66)
		 				try emoji()

		 				break
		 			case .VAR_BEG:fallthrough
		 			case .STR_VAR_BEG:
		 				setState(67)
		 				try variable()

		 				break
		 			case .CHAR:fallthrough
		 			case .WS:fallthrough
		 			case .ANY:
		 				setState(68)
		 				try plain()

		 				break
		 			default:
		 				throw ANTLRException.recognition(e: NoViableAltException(self))
		 			}

		 			break
		 		default:
		 			throw ANTLRException.recognition(e: NoViableAltException(self))
		 		}
		 		setState(71)
		 		try _errHandler.sync(self)
		 		_alt = try getInterpreter().adaptivePredict(_input, 8, _ctx)
		 	} while (_alt != 2 && _alt != ATN.INVALID_ALT_NUMBER)
		} catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	class EmojiContext: ParserRuleContext {
			open
			func EMOJI() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.EMOJI.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_emoji
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterEmoji(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitEmoji(self)
			}
		}
	}
	@discardableResult
	 func emoji() throws -> EmojiContext {
		var _localctx = EmojiContext(_ctx, getState())
		try enterRule(_localctx, 10, TextBlockParser.RULE_emoji)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(73)
		 	try match(TextBlockParser.Tokens.EMOJI.rawValue)
		} catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	class VariableContext: ParserRuleContext {
			open
			func VAR_NAME() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.VAR_NAME.rawValue, 0)
			}
			open
			func VAR_END() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.VAR_END.rawValue, 0)
			}
			open
			func VAR_BEG() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.VAR_BEG.rawValue, 0)
			}
			open
			func STR_VAR_BEG() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.STR_VAR_BEG.rawValue, 0)
			}
			open
			func VAR_BAR() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.VAR_BAR.rawValue, 0)
			}
			open
			func variableFallback() -> VariableFallbackContext? {
				return getRuleContext(VariableFallbackContext.self, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_variable
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterVariable(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitVariable(self)
			}
		}
	}
	@discardableResult
	 func variable() throws -> VariableContext {
		var _localctx = VariableContext(_ctx, getState())
		try enterRule(_localctx, 12, TextBlockParser.RULE_variable)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(75)
		 	_la = try _input.LA(1)
		 	if (!(//closure
		 	 { () -> Bool in
		 	      let testSet: Bool = _la == TextBlockParser.Tokens.VAR_BEG.rawValue || _la == TextBlockParser.Tokens.STR_VAR_BEG.rawValue
		 	      return testSet
		 	 }())) {
		 	try _errHandler.recoverInline(self)
		 	} else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}
		 	setState(76)
		 	try match(TextBlockParser.Tokens.VAR_NAME.rawValue)
		 	setState(79)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	if (//closure
		 	 { () -> Bool in
		 	      let testSet: Bool = _la == TextBlockParser.Tokens.VAR_BAR.rawValue
		 	      return testSet
		 	 }()) {
		 		setState(77)
		 		try match(TextBlockParser.Tokens.VAR_BAR.rawValue)
		 		setState(78)
		 		try variableFallback()
		 	}

		 	setState(81)
		 	try match(TextBlockParser.Tokens.VAR_END.rawValue)
		} catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	class VariableFallbackContext: ParserRuleContext {
			open
			func escape() -> [EscapeContext] {
				return getRuleContexts(EscapeContext.self)
			}
			open
			func escape(_ i: Int) -> EscapeContext? {
				return getRuleContext(EscapeContext.self, i)
			}
			open
			func VAR_NAME() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.VAR_NAME.rawValue)
			}
			open
			func VAR_NAME(_ i: Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.VAR_NAME.rawValue, i)
			}
			open
			func VAR_UNI() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.VAR_UNI.rawValue)
			}
			open
			func VAR_UNI(_ i: Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.VAR_UNI.rawValue, i)
			}
			open
			func VAR_WS() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.VAR_WS.rawValue)
			}
			open
			func VAR_WS(_ i: Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.VAR_WS.rawValue, i)
			}
			open
			func VAR_ANY() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.VAR_ANY.rawValue)
			}
			open
			func VAR_ANY(_ i: Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.VAR_ANY.rawValue, i)
			}
		override open
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_variableFallback
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterVariableFallback(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitVariableFallback(self)
			}
		}
	}
	@discardableResult
	 func variableFallback() throws -> VariableFallbackContext {
		var _localctx = VariableFallbackContext(_ctx, getState())
		try enterRule(_localctx, 14, TextBlockParser.RULE_variableFallback)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(90)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (//closure
		 	 { () -> Bool in
		 	      let testSet: Bool = {  () -> Bool in
		 	   let testArray: [Int] = [_la, TextBlockParser.Tokens.ESCAPED.rawValue, TextBlockParser.Tokens.STR_ESCAPED.rawValue, TextBlockParser.Tokens.VAR_ESCAPED.rawValue, TextBlockParser.Tokens.VAR_NAME.rawValue, TextBlockParser.Tokens.VAR_UNI.rawValue, TextBlockParser.Tokens.VAR_WS.rawValue, TextBlockParser.Tokens.VAR_ANY.rawValue]
		 	    return  Utils.testBitLeftShiftArray(testArray, 0)
		 	}()
		 	      return testSet
		 	 }()) {
		 		setState(88)
		 		try _errHandler.sync(self)
		 		switch (TextBlockParser.Tokens(rawValue: try _input.LA(1))!) {
		 		case .ESCAPED:fallthrough
		 		case .STR_ESCAPED:fallthrough
		 		case .VAR_ESCAPED:
		 			setState(83)
		 			try escape()

		 			break

		 		case .VAR_NAME:
		 			setState(84)
		 			try match(TextBlockParser.Tokens.VAR_NAME.rawValue)

		 			break

		 		case .VAR_UNI:
		 			setState(85)
		 			try match(TextBlockParser.Tokens.VAR_UNI.rawValue)

		 			break

		 		case .VAR_WS:
		 			setState(86)
		 			try match(TextBlockParser.Tokens.VAR_WS.rawValue)

		 			break

		 		case .VAR_ANY:
		 			setState(87)
		 			try match(TextBlockParser.Tokens.VAR_ANY.rawValue)

		 			break
		 		default:
		 			throw ANTLRException.recognition(e: NoViableAltException(self))
		 		}

		 		setState(92)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 	}
		} catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	class PlainContext: ParserRuleContext {
			open
			func CHAR() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.CHAR.rawValue)
			}
			open
			func CHAR(_ i: Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.CHAR.rawValue, i)
			}
			open
			func ANY() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.ANY.rawValue)
			}
			open
			func ANY(_ i: Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.ANY.rawValue, i)
			}
			open
			func WS() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.WS.rawValue)
			}
			open
			func WS(_ i: Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.WS.rawValue, i)
			}
		override open
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_plain
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterPlain(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitPlain(self)
			}
		}
	}
	@discardableResult
	 func plain() throws -> PlainContext {
		var _localctx = PlainContext(_ctx, getState())
		try enterRule(_localctx, 16, TextBlockParser.RULE_plain)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
			var _alt: Int
		 	try enterOuterAlt(_localctx, 1)
		 	setState(94)
		 	try _errHandler.sync(self)
		 	_alt = 1
		 	repeat {
		 		switch (_alt) {
		 		case 1:
		 			setState(93)
		 			_la = try _input.LA(1)
		 			if (!(//closure
		 			 { () -> Bool in
		 			      let testSet: Bool = {  () -> Bool in
		 			   let testArray: [Int] = [_la, TextBlockParser.Tokens.CHAR.rawValue, TextBlockParser.Tokens.WS.rawValue, TextBlockParser.Tokens.ANY.rawValue]
		 			    return  Utils.testBitLeftShiftArray(testArray, 0)
		 			}()
		 			      return testSet
		 			 }())) {
		 			try _errHandler.recoverInline(self)
		 			} else {
		 				_errHandler.reportMatch(self)
		 				try consume()
		 			}

		 			break
		 		default:
		 			throw ANTLRException.recognition(e: NoViableAltException(self))
		 		}
		 		setState(96)
		 		try _errHandler.sync(self)
		 		_alt = try getInterpreter().adaptivePredict(_input, 12, _ctx)
		 	} while (_alt != 2 && _alt != ATN.INVALID_ALT_NUMBER)
		} catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	class EscapeContext: ParserRuleContext {
			open
			func ESCAPED() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.ESCAPED.rawValue, 0)
			}
			open
			func STR_ESCAPED() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.STR_ESCAPED.rawValue, 0)
			}
			open
			func VAR_ESCAPED() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.VAR_ESCAPED.rawValue, 0)
			}
		override open
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_escape
		}
		override open
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterEscape(self)
			}
		}
		override open
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitEscape(self)
			}
		}
	}
	@discardableResult
	 func escape() throws -> EscapeContext {
		var _localctx = EscapeContext(_ctx, getState())
		try enterRule(_localctx, 18, TextBlockParser.RULE_escape)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(98)
		 	_la = try _input.LA(1)
		 	if (!(//closure
		 	 { () -> Bool in
		 	      let testSet: Bool = {  () -> Bool in
		 	   let testArray: [Int] = [_la, TextBlockParser.Tokens.ESCAPED.rawValue, TextBlockParser.Tokens.STR_ESCAPED.rawValue, TextBlockParser.Tokens.VAR_ESCAPED.rawValue]
		 	    return  Utils.testBitLeftShiftArray(testArray, 0)
		 	}()
		 	      return testSet
		 	 }())) {
		 	try _errHandler.recoverInline(self)
		 	} else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}
		} catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	public
	static let _serializedATN = TextBlockParserATN().jsonString

	public
	static let _ATN = ATNDeserializer().deserializeFromJson(_serializedATN)
}
