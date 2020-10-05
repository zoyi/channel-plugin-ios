// Generated from TextBlockParser.g4 by ANTLR 4.7.1

/**
 * This interface defines a complete listener for a parse tree produced by
 * {@link TextBlockParser}.
 */
protocol TextBlockParserListener: ParseTreeListener {
	/**
	 * Enter a parse tree produced by {@link TextBlockParser#block}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterBlock(_ ctx: TextBlockParser.BlockContext)
	/**
	 * Exit a parse tree produced by {@link TextBlockParser#block}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitBlock(_ ctx: TextBlockParser.BlockContext)
	/**
	 * Enter a parse tree produced by {@link TextBlockParser#tag}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterTag(_ ctx: TextBlockParser.TagContext)
	/**
	 * Exit a parse tree produced by {@link TextBlockParser#tag}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitTag(_ ctx: TextBlockParser.TagContext)
	/**
	 * Enter a parse tree produced by {@link TextBlockParser#attribute}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterAttribute(_ ctx: TextBlockParser.AttributeContext)
	/**
	 * Exit a parse tree produced by {@link TextBlockParser#attribute}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitAttribute(_ ctx: TextBlockParser.AttributeContext)
	/**
	 * Enter a parse tree produced by {@link TextBlockParser#attrValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterAttrValue(_ ctx: TextBlockParser.AttrValueContext)
	/**
	 * Exit a parse tree produced by {@link TextBlockParser#attrValue}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitAttrValue(_ ctx: TextBlockParser.AttrValueContext)
	/**
	 * Enter a parse tree produced by {@link TextBlockParser#content}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterContent(_ ctx: TextBlockParser.ContentContext)
	/**
	 * Exit a parse tree produced by {@link TextBlockParser#content}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitContent(_ ctx: TextBlockParser.ContentContext)
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
	 * Enter a parse tree produced by {@link TextBlockParser#variable}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterVariable(_ ctx: TextBlockParser.VariableContext)
	/**
	 * Exit a parse tree produced by {@link TextBlockParser#variable}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitVariable(_ ctx: TextBlockParser.VariableContext)
	/**
	 * Enter a parse tree produced by {@link TextBlockParser#variableFallback}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterVariableFallback(_ ctx: TextBlockParser.VariableFallbackContext)
	/**
	 * Exit a parse tree produced by {@link TextBlockParser#variableFallback}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitVariableFallback(_ ctx: TextBlockParser.VariableFallbackContext)
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
	/**
	 * Enter a parse tree produced by {@link TextBlockParser#escape}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterEscape(_ ctx: TextBlockParser.EscapeContext)
	/**
	 * Exit a parse tree produced by {@link TextBlockParser#escape}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitEscape(_ ctx: TextBlockParser.EscapeContext)
}
