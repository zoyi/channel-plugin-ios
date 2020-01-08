// Generated from TextBlockParser.g4 by ANTLR 4.7.1

internal class TextBlockParser: Parser {

	internal static var _decisionToDFA: [DFA] = {
          var decisionToDFA = [DFA]()
          let length = TextBlockParser._ATN.getNumberOfDecisions()
          for i in 0..<length {
            decisionToDFA.append(DFA(TextBlockParser._ATN.getDecisionState(i)!, i))
           }
           return decisionToDFA
     }()

	internal static let _sharedContextCache = PredictionContextCache()

	internal
	enum Tokens: Int {
		case EOF = -1, GL = 1, ESCAPED_GL = 2, ESCAPED_GR = 3, ESCAPED_AMP = 4, 
                 WS = 5, COLON = 6, EMOJI_CODES = 7, UNICODES = 8, ANY = 9, 
                 TAG_GR = 10, TAG_SLASH = 11, TAG_EQUALS = 12, BOLD = 13, 
                 ITALIC = 14, LINK = 15, VARIABLE = 16, TAG_WS = 17, ATTR_NAME = 18, 
                 ATTR_VALUE = 19, ATTR_WS = 20
	}

	internal
	static let RULE_text = 0, RULE_bold = 1, RULE_italic = 2, RULE_link = 3, 
            RULE_inner = 4, RULE_variable = 5, RULE_emoji = 6, RULE_plain = 7

	internal
	static let ruleNames: [String] = [
		"text", "bold", "italic", "link", "inner", "variable", "emoji", "plain"
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
	func getGrammarFileName() -> String { return "TextBlockParser.g4" }

	override internal
	func getRuleNames() -> [String] { return TextBlockParser.ruleNames }

	override internal
	func getSerializedATN() -> String { return TextBlockParser._serializedATN }

	override internal
	func getATN() -> ATN { return TextBlockParser._ATN }

	override internal
	func getVocabulary() -> Vocabulary {
	    return TextBlockParser.VOCABULARY
	}

	override internal
	init(_ input:TokenStream) throws {
	    RuntimeMetaData.checkVersion("4.7.1", RuntimeMetaData.VERSION)
		try super.init(input)
		_interp = ParserATNSimulator(self,TextBlockParser._ATN,TextBlockParser._decisionToDFA, TextBlockParser._sharedContextCache)
	}

	internal class TextContext: ParserRuleContext {
			internal
			func EOF() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.EOF.rawValue, 0)
			}
			internal
			func bold() -> [BoldContext] {
				return getRuleContexts(BoldContext.self)
			}
			internal
			func bold(_ i: Int) -> BoldContext? {
				return getRuleContext(BoldContext.self, i)
			}
			internal
			func italic() -> [ItalicContext] {
				return getRuleContexts(ItalicContext.self)
			}
			internal
			func italic(_ i: Int) -> ItalicContext? {
				return getRuleContext(ItalicContext.self, i)
			}
			internal
			func link() -> [LinkContext] {
				return getRuleContexts(LinkContext.self)
			}
			internal
			func link(_ i: Int) -> LinkContext? {
				return getRuleContext(LinkContext.self, i)
			}
			internal
			func inner() -> [InnerContext] {
				return getRuleContexts(InnerContext.self)
			}
			internal
			func inner(_ i: Int) -> InnerContext? {
				return getRuleContext(InnerContext.self, i)
			}
		override internal
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_text
		}
		override internal
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterText(self)
			}
		}
		override internal
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitText(self)
			}
		}
	}
	@discardableResult
	 internal func text() throws -> TextContext {
		var _localctx: TextContext = TextContext(_ctx, getState())
		try enterRule(_localctx, 0, TextBlockParser.RULE_text)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(22)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (//closure
		 	 { () -> Bool in
		 	      let testSet: Bool = {  () -> Bool in
		 	   let testArray: [Int] = [_la, TextBlockParser.Tokens.GL.rawValue,TextBlockParser.Tokens.ESCAPED_GL.rawValue,TextBlockParser.Tokens.ESCAPED_GR.rawValue,TextBlockParser.Tokens.ESCAPED_AMP.rawValue,TextBlockParser.Tokens.WS.rawValue,TextBlockParser.Tokens.COLON.rawValue,TextBlockParser.Tokens.EMOJI_CODES.rawValue,TextBlockParser.Tokens.UNICODES.rawValue,TextBlockParser.Tokens.ANY.rawValue]
		 	    return  Utils.testBitLeftShiftArray(testArray, 0)
		 	}()
		 	      return testSet
		 	 }()) {
		 		setState(20)
		 		try _errHandler.sync(self)
		 		switch(try getInterpreter().adaptivePredict(_input,0, _ctx)) {
		 		case 1:
		 			setState(16)
		 			try bold()

		 			break
		 		case 2:
		 			setState(17)
		 			try italic()

		 			break
		 		case 3:
		 			setState(18)
		 			try link()

		 			break
		 		case 4:
		 			setState(19)
		 			try inner()

		 			break
		 		default: break
		 		}

		 		setState(24)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 	}
		 	setState(25)
		 	try match(TextBlockParser.Tokens.EOF.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	internal class BoldContext: ParserRuleContext {
			internal
			func GL() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.GL.rawValue)
			}
			internal
			func GL(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.GL.rawValue, i)
			}
			internal
			func BOLD() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.BOLD.rawValue)
			}
			internal
			func BOLD(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.BOLD.rawValue, i)
			}
			internal
			func TAG_GR() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.TAG_GR.rawValue)
			}
			internal
			func TAG_GR(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.TAG_GR.rawValue, i)
			}
			internal
			func TAG_SLASH() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.TAG_SLASH.rawValue, 0)
			}
			internal
			func italic() -> [ItalicContext] {
				return getRuleContexts(ItalicContext.self)
			}
			internal
			func italic(_ i: Int) -> ItalicContext? {
				return getRuleContext(ItalicContext.self, i)
			}
			internal
			func link() -> [LinkContext] {
				return getRuleContexts(LinkContext.self)
			}
			internal
			func link(_ i: Int) -> LinkContext? {
				return getRuleContext(LinkContext.self, i)
			}
			internal
			func inner() -> [InnerContext] {
				return getRuleContexts(InnerContext.self)
			}
			internal
			func inner(_ i: Int) -> InnerContext? {
				return getRuleContext(InnerContext.self, i)
			}
		override internal
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_bold
		}
		override internal
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterBold(self)
			}
		}
		override internal
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitBold(self)
			}
		}
	}
	@discardableResult
	 internal func bold() throws -> BoldContext {
		var _localctx: BoldContext = BoldContext(_ctx, getState())
		try enterRule(_localctx, 2, TextBlockParser.RULE_bold)
		defer {
	    		try! exitRule()
	    }
		do {
			var _alt:Int
		 	try enterOuterAlt(_localctx, 1)
		 	setState(27)
		 	try match(TextBlockParser.Tokens.GL.rawValue)
		 	setState(28)
		 	try match(TextBlockParser.Tokens.BOLD.rawValue)
		 	setState(29)
		 	try match(TextBlockParser.Tokens.TAG_GR.rawValue)
		 	setState(33); 
		 	try _errHandler.sync(self)
		 	_alt = 1;
		 	repeat {
		 		switch (_alt) {
		 		case 1:
		 			setState(33)
		 			try _errHandler.sync(self)
		 			switch(try getInterpreter().adaptivePredict(_input,2, _ctx)) {
		 			case 1:
		 				setState(30)
		 				try italic()

		 				break
		 			case 2:
		 				setState(31)
		 				try link()

		 				break
		 			case 3:
		 				setState(32)
		 				try inner()

		 				break
		 			default: break
		 			}

		 			break
		 		default:
		 			throw ANTLRException.recognition(e: NoViableAltException(self))
		 		}
		 		setState(35); 
		 		try _errHandler.sync(self)
		 		_alt = try getInterpreter().adaptivePredict(_input,3,_ctx)
		 	} while (_alt != 2 && _alt !=  ATN.INVALID_ALT_NUMBER)
		 	setState(37)
		 	try match(TextBlockParser.Tokens.GL.rawValue)
		 	setState(38)
		 	try match(TextBlockParser.Tokens.TAG_SLASH.rawValue)
		 	setState(39)
		 	try match(TextBlockParser.Tokens.BOLD.rawValue)
		 	setState(40)
		 	try match(TextBlockParser.Tokens.TAG_GR.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	internal class ItalicContext: ParserRuleContext {
			internal
			func GL() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.GL.rawValue)
			}
			internal
			func GL(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.GL.rawValue, i)
			}
			internal
			func ITALIC() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.ITALIC.rawValue)
			}
			internal
			func ITALIC(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.ITALIC.rawValue, i)
			}
			internal
			func TAG_GR() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.TAG_GR.rawValue)
			}
			internal
			func TAG_GR(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.TAG_GR.rawValue, i)
			}
			internal
			func TAG_SLASH() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.TAG_SLASH.rawValue, 0)
			}
			internal
			func link() -> [LinkContext] {
				return getRuleContexts(LinkContext.self)
			}
			internal
			func link(_ i: Int) -> LinkContext? {
				return getRuleContext(LinkContext.self, i)
			}
			internal
			func inner() -> [InnerContext] {
				return getRuleContexts(InnerContext.self)
			}
			internal
			func inner(_ i: Int) -> InnerContext? {
				return getRuleContext(InnerContext.self, i)
			}
		override internal
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_italic
		}
		override internal
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterItalic(self)
			}
		}
		override internal
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitItalic(self)
			}
		}
	}
	@discardableResult
	 internal func italic() throws -> ItalicContext {
		var _localctx: ItalicContext = ItalicContext(_ctx, getState())
		try enterRule(_localctx, 4, TextBlockParser.RULE_italic)
		defer {
	    		try! exitRule()
	    }
		do {
			var _alt:Int
		 	try enterOuterAlt(_localctx, 1)
		 	setState(42)
		 	try match(TextBlockParser.Tokens.GL.rawValue)
		 	setState(43)
		 	try match(TextBlockParser.Tokens.ITALIC.rawValue)
		 	setState(44)
		 	try match(TextBlockParser.Tokens.TAG_GR.rawValue)
		 	setState(47); 
		 	try _errHandler.sync(self)
		 	_alt = 1;
		 	repeat {
		 		switch (_alt) {
		 		case 1:
		 			setState(47)
		 			try _errHandler.sync(self)
		 			switch(try getInterpreter().adaptivePredict(_input,4, _ctx)) {
		 			case 1:
		 				setState(45)
		 				try link()

		 				break
		 			case 2:
		 				setState(46)
		 				try inner()

		 				break
		 			default: break
		 			}

		 			break
		 		default:
		 			throw ANTLRException.recognition(e: NoViableAltException(self))
		 		}
		 		setState(49); 
		 		try _errHandler.sync(self)
		 		_alt = try getInterpreter().adaptivePredict(_input,5,_ctx)
		 	} while (_alt != 2 && _alt !=  ATN.INVALID_ALT_NUMBER)
		 	setState(51)
		 	try match(TextBlockParser.Tokens.GL.rawValue)
		 	setState(52)
		 	try match(TextBlockParser.Tokens.TAG_SLASH.rawValue)
		 	setState(53)
		 	try match(TextBlockParser.Tokens.ITALIC.rawValue)
		 	setState(54)
		 	try match(TextBlockParser.Tokens.TAG_GR.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	internal class LinkContext: ParserRuleContext {
			internal
			func GL() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.GL.rawValue)
			}
			internal
			func GL(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.GL.rawValue, i)
			}
			internal
			func LINK() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.LINK.rawValue)
			}
			internal
			func LINK(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.LINK.rawValue, i)
			}
			internal
			func TAG_GR() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.TAG_GR.rawValue)
			}
			internal
			func TAG_GR(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.TAG_GR.rawValue, i)
			}
			internal
			func TAG_SLASH() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.TAG_SLASH.rawValue, 0)
			}
			internal
			func ATTR_NAME() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.ATTR_NAME.rawValue)
			}
			internal
			func ATTR_NAME(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.ATTR_NAME.rawValue, i)
			}
			internal
			func TAG_EQUALS() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.TAG_EQUALS.rawValue)
			}
			internal
			func TAG_EQUALS(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.TAG_EQUALS.rawValue, i)
			}
			internal
			func ATTR_VALUE() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.ATTR_VALUE.rawValue)
			}
			internal
			func ATTR_VALUE(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.ATTR_VALUE.rawValue, i)
			}
			internal
			func inner() -> [InnerContext] {
				return getRuleContexts(InnerContext.self)
			}
			internal
			func inner(_ i: Int) -> InnerContext? {
				return getRuleContext(InnerContext.self, i)
			}
		override internal
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_link
		}
		override internal
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterLink(self)
			}
		}
		override internal
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitLink(self)
			}
		}
	}
	@discardableResult
	 internal func link() throws -> LinkContext {
		var _localctx: LinkContext = LinkContext(_ctx, getState())
		try enterRule(_localctx, 6, TextBlockParser.RULE_link)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
			var _alt:Int
		 	try enterOuterAlt(_localctx, 1)
		 	setState(56)
		 	try match(TextBlockParser.Tokens.GL.rawValue)
		 	setState(57)
		 	try match(TextBlockParser.Tokens.LINK.rawValue)
		 	setState(63)
		 	try _errHandler.sync(self)
		 	_la = try _input.LA(1)
		 	while (//closure
		 	 { () -> Bool in
		 	      let testSet: Bool = _la == TextBlockParser.Tokens.ATTR_NAME.rawValue
		 	      return testSet
		 	 }()) {
		 		setState(58)
		 		try match(TextBlockParser.Tokens.ATTR_NAME.rawValue)
		 		setState(59)
		 		try match(TextBlockParser.Tokens.TAG_EQUALS.rawValue)
		 		setState(60)
		 		try match(TextBlockParser.Tokens.ATTR_VALUE.rawValue)


		 		setState(65)
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 	}
		 	setState(66)
		 	try match(TextBlockParser.Tokens.TAG_GR.rawValue)
		 	setState(68); 
		 	try _errHandler.sync(self)
		 	_alt = 1;
		 	repeat {
		 		switch (_alt) {
		 		case 1:
		 			setState(67)
		 			try inner()


		 			break
		 		default:
		 			throw ANTLRException.recognition(e: NoViableAltException(self))
		 		}
		 		setState(70); 
		 		try _errHandler.sync(self)
		 		_alt = try getInterpreter().adaptivePredict(_input,7,_ctx)
		 	} while (_alt != 2 && _alt !=  ATN.INVALID_ALT_NUMBER)
		 	setState(72)
		 	try match(TextBlockParser.Tokens.GL.rawValue)
		 	setState(73)
		 	try match(TextBlockParser.Tokens.TAG_SLASH.rawValue)
		 	setState(74)
		 	try match(TextBlockParser.Tokens.LINK.rawValue)
		 	setState(75)
		 	try match(TextBlockParser.Tokens.TAG_GR.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	internal class InnerContext: ParserRuleContext {
			internal
			func variable() -> VariableContext? {
				return getRuleContext(VariableContext.self, 0)
			}
			internal
			func emoji() -> EmojiContext? {
				return getRuleContext(EmojiContext.self, 0)
			}
			internal
			func plain() -> PlainContext? {
				return getRuleContext(PlainContext.self, 0)
			}
		override internal
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_inner
		}
		override internal
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterInner(self)
			}
		}
		override internal
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitInner(self)
			}
		}
	}
	@discardableResult
	 internal func inner() throws -> InnerContext {
		var _localctx: InnerContext = InnerContext(_ctx, getState())
		try enterRule(_localctx, 8, TextBlockParser.RULE_inner)
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(80)
		 	try _errHandler.sync(self)
		 	switch(try getInterpreter().adaptivePredict(_input,8, _ctx)) {
		 	case 1:
		 		try enterOuterAlt(_localctx, 1)
		 		setState(77)
		 		try variable()

		 		break
		 	case 2:
		 		try enterOuterAlt(_localctx, 2)
		 		setState(78)
		 		try emoji()

		 		break
		 	case 3:
		 		try enterOuterAlt(_localctx, 3)
		 		setState(79)
		 		try plain()

		 		break
		 	default: break
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	internal class VariableContext: ParserRuleContext {
		override internal
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_variable
		}
	 
		internal
		func copyFrom(_ ctx: VariableContext) {
			super.copyFrom(ctx)
		}
	}
	internal class VariableWithoutFallbackContext: VariableContext {
			internal
			func GL() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.GL.rawValue, 0)
			}
			internal
			func VARIABLE() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.VARIABLE.rawValue, 0)
			}
			internal
			func TAG_SLASH() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.TAG_SLASH.rawValue, 0)
			}
			internal
			func TAG_GR() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.TAG_GR.rawValue, 0)
			}
			internal
			func ATTR_NAME() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.ATTR_NAME.rawValue)
			}
			internal
			func ATTR_NAME(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.ATTR_NAME.rawValue, i)
			}
			internal
			func TAG_EQUALS() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.TAG_EQUALS.rawValue)
			}
			internal
			func TAG_EQUALS(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.TAG_EQUALS.rawValue, i)
			}
			internal
			func ATTR_VALUE() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.ATTR_VALUE.rawValue)
			}
			internal
			func ATTR_VALUE(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.ATTR_VALUE.rawValue, i)
			}

		internal
		init(_ ctx: VariableContext) {
			super.init()
			copyFrom(ctx)
		}
		override internal
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterVariableWithoutFallback(self)
			}
		}
		override internal
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitVariableWithoutFallback(self)
			}
		}
	}
	internal class VariableWithFallbackContext: VariableContext {
			internal
			func GL() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.GL.rawValue)
			}
			internal
			func GL(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.GL.rawValue, i)
			}
			internal
			func VARIABLE() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.VARIABLE.rawValue)
			}
			internal
			func VARIABLE(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.VARIABLE.rawValue, i)
			}
			internal
			func TAG_GR() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.TAG_GR.rawValue)
			}
			internal
			func TAG_GR(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.TAG_GR.rawValue, i)
			}
			internal
			func TAG_SLASH() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.TAG_SLASH.rawValue, 0)
			}
			internal
			func ATTR_NAME() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.ATTR_NAME.rawValue)
			}
			internal
			func ATTR_NAME(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.ATTR_NAME.rawValue, i)
			}
			internal
			func TAG_EQUALS() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.TAG_EQUALS.rawValue)
			}
			internal
			func TAG_EQUALS(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.TAG_EQUALS.rawValue, i)
			}
			internal
			func ATTR_VALUE() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.ATTR_VALUE.rawValue)
			}
			internal
			func ATTR_VALUE(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.ATTR_VALUE.rawValue, i)
			}
			internal
			func emoji() -> [EmojiContext] {
				return getRuleContexts(EmojiContext.self)
			}
			internal
			func emoji(_ i: Int) -> EmojiContext? {
				return getRuleContext(EmojiContext.self, i)
			}
			internal
			func plain() -> [PlainContext] {
				return getRuleContexts(PlainContext.self)
			}
			internal
			func plain(_ i: Int) -> PlainContext? {
				return getRuleContext(PlainContext.self, i)
			}

		internal
		init(_ ctx: VariableContext) {
			super.init()
			copyFrom(ctx)
		}
		override internal
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterVariableWithFallback(self)
			}
		}
		override internal
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitVariableWithFallback(self)
			}
		}
	}
	@discardableResult
	 internal func variable() throws -> VariableContext {
		var _localctx: VariableContext = VariableContext(_ctx, getState())
		try enterRule(_localctx, 10, TextBlockParser.RULE_variable)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	setState(114)
		 	try _errHandler.sync(self)
		 	switch(try getInterpreter().adaptivePredict(_input,13, _ctx)) {
		 	case 1:
		 		_localctx =  VariableWithFallbackContext(_localctx);
		 		try enterOuterAlt(_localctx, 1)
		 		setState(82)
		 		try match(TextBlockParser.Tokens.GL.rawValue)
		 		setState(83)
		 		try match(TextBlockParser.Tokens.VARIABLE.rawValue)
		 		setState(87) 
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 		repeat {
		 			setState(84)
		 			try match(TextBlockParser.Tokens.ATTR_NAME.rawValue)
		 			setState(85)
		 			try match(TextBlockParser.Tokens.TAG_EQUALS.rawValue)
		 			setState(86)
		 			try match(TextBlockParser.Tokens.ATTR_VALUE.rawValue)


		 			setState(89); 
		 			try _errHandler.sync(self)
		 			_la = try _input.LA(1)
		 		} while (//closure
		 		 { () -> Bool in
		 		      let testSet: Bool = _la == TextBlockParser.Tokens.ATTR_NAME.rawValue
		 		      return testSet
		 		 }())
		 		setState(91)
		 		try match(TextBlockParser.Tokens.TAG_GR.rawValue)
		 		setState(94) 
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 		repeat {
		 			setState(94)
		 			try _errHandler.sync(self)
		 			switch(try getInterpreter().adaptivePredict(_input,10, _ctx)) {
		 			case 1:
		 				setState(92)
		 				try emoji()

		 				break
		 			case 2:
		 				setState(93)
		 				try plain()

		 				break
		 			default: break
		 			}

		 			setState(96); 
		 			try _errHandler.sync(self)
		 			_la = try _input.LA(1)
		 		} while (//closure
		 		 { () -> Bool in
		 		      let testSet: Bool = {  () -> Bool in
		 		   let testArray: [Int] = [_la, TextBlockParser.Tokens.ESCAPED_GL.rawValue,TextBlockParser.Tokens.ESCAPED_GR.rawValue,TextBlockParser.Tokens.ESCAPED_AMP.rawValue,TextBlockParser.Tokens.WS.rawValue,TextBlockParser.Tokens.COLON.rawValue,TextBlockParser.Tokens.EMOJI_CODES.rawValue,TextBlockParser.Tokens.UNICODES.rawValue,TextBlockParser.Tokens.ANY.rawValue]
		 		    return  Utils.testBitLeftShiftArray(testArray, 0)
		 		}()
		 		      return testSet
		 		 }())
		 		setState(98)
		 		try match(TextBlockParser.Tokens.GL.rawValue)
		 		setState(99)
		 		try match(TextBlockParser.Tokens.TAG_SLASH.rawValue)
		 		setState(100)
		 		try match(TextBlockParser.Tokens.VARIABLE.rawValue)
		 		setState(101)
		 		try match(TextBlockParser.Tokens.TAG_GR.rawValue)

		 		break
		 	case 2:
		 		_localctx =  VariableWithoutFallbackContext(_localctx);
		 		try enterOuterAlt(_localctx, 2)
		 		setState(103)
		 		try match(TextBlockParser.Tokens.GL.rawValue)
		 		setState(104)
		 		try match(TextBlockParser.Tokens.VARIABLE.rawValue)
		 		setState(108) 
		 		try _errHandler.sync(self)
		 		_la = try _input.LA(1)
		 		repeat {
		 			setState(105)
		 			try match(TextBlockParser.Tokens.ATTR_NAME.rawValue)
		 			setState(106)
		 			try match(TextBlockParser.Tokens.TAG_EQUALS.rawValue)
		 			setState(107)
		 			try match(TextBlockParser.Tokens.ATTR_VALUE.rawValue)


		 			setState(110); 
		 			try _errHandler.sync(self)
		 			_la = try _input.LA(1)
		 		} while (//closure
		 		 { () -> Bool in
		 		      let testSet: Bool = _la == TextBlockParser.Tokens.ATTR_NAME.rawValue
		 		      return testSet
		 		 }())
		 		setState(112)
		 		try match(TextBlockParser.Tokens.TAG_SLASH.rawValue)
		 		setState(113)
		 		try match(TextBlockParser.Tokens.TAG_GR.rawValue)

		 		break
		 	default: break
		 	}
		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	internal class EmojiContext: ParserRuleContext {
			internal
			func COLON() -> [TerminalNode] {
				return getTokens(TextBlockParser.Tokens.COLON.rawValue)
			}
			internal
			func COLON(_ i:Int) -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.COLON.rawValue, i)
			}
			internal
			func EMOJI_CODES() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.EMOJI_CODES.rawValue, 0)
			}
		override internal
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_emoji
		}
		override internal
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterEmoji(self)
			}
		}
		override internal
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitEmoji(self)
			}
		}
	}
	@discardableResult
	 internal func emoji() throws -> EmojiContext {
		var _localctx: EmojiContext = EmojiContext(_ctx, getState())
		try enterRule(_localctx, 12, TextBlockParser.RULE_emoji)
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(116)
		 	try match(TextBlockParser.Tokens.COLON.rawValue)
		 	setState(117)
		 	try match(TextBlockParser.Tokens.EMOJI_CODES.rawValue)
		 	setState(118)
		 	try match(TextBlockParser.Tokens.COLON.rawValue)

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}

	internal class PlainContext: ParserRuleContext {
			internal
			func COLON() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.COLON.rawValue, 0)
			}
			internal
			func EMOJI_CODES() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.EMOJI_CODES.rawValue, 0)
			}
			internal
			func ESCAPED_GL() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.ESCAPED_GL.rawValue, 0)
			}
			internal
			func ESCAPED_GR() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.ESCAPED_GR.rawValue, 0)
			}
			internal
			func ESCAPED_AMP() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.ESCAPED_AMP.rawValue, 0)
			}
			internal
			func WS() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.WS.rawValue, 0)
			}
			internal
			func UNICODES() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.UNICODES.rawValue, 0)
			}
			internal
			func ANY() -> TerminalNode? {
				return getToken(TextBlockParser.Tokens.ANY.rawValue, 0)
			}
		override internal
		func getRuleIndex() -> Int {
			return TextBlockParser.RULE_plain
		}
		override internal
		func enterRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.enterPlain(self)
			}
		}
		override internal
		func exitRule(_ listener: ParseTreeListener) {
			if let listener = listener as? TextBlockParserListener {
				listener.exitPlain(self)
			}
		}
	}
	@discardableResult
	 internal func plain() throws -> PlainContext {
		var _localctx: PlainContext = PlainContext(_ctx, getState())
		try enterRule(_localctx, 14, TextBlockParser.RULE_plain)
		var _la: Int = 0
		defer {
	    		try! exitRule()
	    }
		do {
		 	try enterOuterAlt(_localctx, 1)
		 	setState(120)
		 	_la = try _input.LA(1)
		 	if (!(//closure
		 	 { () -> Bool in
		 	      let testSet: Bool = {  () -> Bool in
		 	   let testArray: [Int] = [_la, TextBlockParser.Tokens.ESCAPED_GL.rawValue,TextBlockParser.Tokens.ESCAPED_GR.rawValue,TextBlockParser.Tokens.ESCAPED_AMP.rawValue,TextBlockParser.Tokens.WS.rawValue,TextBlockParser.Tokens.COLON.rawValue,TextBlockParser.Tokens.EMOJI_CODES.rawValue,TextBlockParser.Tokens.UNICODES.rawValue,TextBlockParser.Tokens.ANY.rawValue]
		 	    return  Utils.testBitLeftShiftArray(testArray, 0)
		 	}()
		 	      return testSet
		 	 }())) {
		 	try _errHandler.recoverInline(self)
		 	}
		 	else {
		 		_errHandler.reportMatch(self)
		 		try consume()
		 	}

		}
		catch ANTLRException.recognition(let re) {
			_localctx.exception = re
			_errHandler.reportError(self, re)
			try _errHandler.recover(self, re)
		}

		return _localctx
	}


	internal
	static let _serializedATN = TextBlockParserATN().jsonString

	internal
	static let _ATN = ATNDeserializer().deserializeFromJson(_serializedATN)
}
