// Generated from TextBlockParser.g4 by ANTLR 4.7.1

/**
 * This interface defines a complete listener for a parse tree produced by
 * {@link TextBlockParser}.
 */
internal protocol TextBlockParserListener: ParseTreeListener {
	/**
	 * Enter a parse tree produced by {@link TextBlockParser#text}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterText(_ ctx: TextBlockParser.TextContext)
	/**
	 * Exit a parse tree produced by {@link TextBlockParser#text}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitText(_ ctx: TextBlockParser.TextContext)
	/**
	 * Enter a parse tree produced by {@link TextBlockParser#bold}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterBold(_ ctx: TextBlockParser.BoldContext)
	/**
	 * Exit a parse tree produced by {@link TextBlockParser#bold}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitBold(_ ctx: TextBlockParser.BoldContext)
	/**
	 * Enter a parse tree produced by {@link TextBlockParser#italic}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterItalic(_ ctx: TextBlockParser.ItalicContext)
	/**
	 * Exit a parse tree produced by {@link TextBlockParser#italic}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitItalic(_ ctx: TextBlockParser.ItalicContext)
	/**
	 * Enter a parse tree produced by {@link TextBlockParser#link}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterLink(_ ctx: TextBlockParser.LinkContext)
	/**
	 * Exit a parse tree produced by {@link TextBlockParser#link}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitLink(_ ctx: TextBlockParser.LinkContext)
	/**
	 * Enter a parse tree produced by {@link TextBlockParser#inner}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterInner(_ ctx: TextBlockParser.InnerContext)
	/**
	 * Exit a parse tree produced by {@link TextBlockParser#inner}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitInner(_ ctx: TextBlockParser.InnerContext)
	/**
	 * Enter a parse tree produced by the {@code VariableWithFallback}
	 * labeled alternative in {@link TextBlockParser#variable}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterVariableWithFallback(_ ctx: TextBlockParser.VariableWithFallbackContext)
	/**
	 * Exit a parse tree produced by the {@code VariableWithFallback}
	 * labeled alternative in {@link TextBlockParser#variable}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitVariableWithFallback(_ ctx: TextBlockParser.VariableWithFallbackContext)
	/**
	 * Enter a parse tree produced by the {@code VariableWithoutFallback}
	 * labeled alternative in {@link TextBlockParser#variable}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterVariableWithoutFallback(_ ctx: TextBlockParser.VariableWithoutFallbackContext)
	/**
	 * Exit a parse tree produced by the {@code VariableWithoutFallback}
	 * labeled alternative in {@link TextBlockParser#variable}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitVariableWithoutFallback(_ ctx: TextBlockParser.VariableWithoutFallbackContext)
	/**
	 * Enter a parse tree produced by {@link TextBlockParser#emoji}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterEmoji(_ ctx: TextBlockParser.EmojiContext)
	/**
	 * Exit a parse tree produced by {@link TextBlockParser#emoji}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitEmoji(_ ctx: TextBlockParser.EmojiContext)
	/**
	 * Enter a parse tree produced by {@link TextBlockParser#plain}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterPlain(_ ctx: TextBlockParser.PlainContext)
	/**
	 * Exit a parse tree produced by {@link TextBlockParser#plain}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitPlain(_ ctx: TextBlockParser.PlainContext)
}
