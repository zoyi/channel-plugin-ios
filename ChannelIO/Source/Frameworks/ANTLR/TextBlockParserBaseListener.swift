// Generated from TextBlockParser.g4 by ANTLR 4.7.1


/**
 * This class provides an empty implementation of {@link TextBlockParserListener},
 * which can be extended to create a listener which only needs to handle a subset
 * of the available methods.
 */
class TextBlockParserBaseListener: TextBlockParserListener {
     init() { }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func enterBlock(_ ctx: TextBlockParser.BlockContext) { }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func exitBlock(_ ctx: TextBlockParser.BlockContext) { }

	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func enterTag(_ ctx: TextBlockParser.TagContext) { }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func exitTag(_ ctx: TextBlockParser.TagContext) { }

	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func enterAttribute(_ ctx: TextBlockParser.AttributeContext) { }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func exitAttribute(_ ctx: TextBlockParser.AttributeContext) { }

	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func enterAttrValue(_ ctx: TextBlockParser.AttrValueContext) { }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func exitAttrValue(_ ctx: TextBlockParser.AttrValueContext) { }

	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func enterContent(_ ctx: TextBlockParser.ContentContext) { }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func exitContent(_ ctx: TextBlockParser.ContentContext) { }

	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func enterEmoji(_ ctx: TextBlockParser.EmojiContext) { }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func exitEmoji(_ ctx: TextBlockParser.EmojiContext) { }

	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func enterVariable(_ ctx: TextBlockParser.VariableContext) { }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func exitVariable(_ ctx: TextBlockParser.VariableContext) { }

	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func enterVariableFallback(_ ctx: TextBlockParser.VariableFallbackContext) { }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func exitVariableFallback(_ ctx: TextBlockParser.VariableFallbackContext) { }

	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func enterPlain(_ ctx: TextBlockParser.PlainContext) { }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func exitPlain(_ ctx: TextBlockParser.PlainContext) { }

	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func enterEscape(_ ctx: TextBlockParser.EscapeContext) { }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func exitEscape(_ ctx: TextBlockParser.EscapeContext) { }

	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func enterEveryRule(_ ctx: ParserRuleContext) { }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func exitEveryRule(_ ctx: ParserRuleContext) { }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func visitTerminal(_ node: TerminalNode) { }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation does nothing.</p>
	 */
	func visitErrorNode(_ node: ErrorNode) { }
}
