parser grammar TextBlockParser;

options { tokenVocab = TextBlockLexer; }

block: (tag | content)* EOF;

tag: LT TAG_NAME (attribute)* GT (tag | content)* LT SLASH TAG_NAME GT;

attribute: TAG_NAME EQUALS STR_BEG attrValue STR_END;

attrValue: (escape | variable | STR_CHAR | STR_ANY | STR_WS)+;

content: (escape | emoji | variable | plain)+;

emoji: EMOJI;

variable: (VAR_BEG | STR_VAR_BEG) VAR_NAME (VAR_BAR variableFallback)? VAR_END;

variableFallback: (escape | VAR_NAME | VAR_UNI | VAR_WS | VAR_ANY)*;

plain: (CHAR | ANY | WS)+;

escape: ESCAPED | STR_ESCAPED | VAR_ESCAPED;


