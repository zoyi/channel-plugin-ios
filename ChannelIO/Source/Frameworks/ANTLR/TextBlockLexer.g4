lexer grammar TextBlockLexer;


LT: '<' -> pushMode(TAG);

VAR_BEG: '${' -> pushMode(VAR);

ESCAPED: Escaped;

EMOJI: ':' [-+_0-9a-zA-Z]+ ':';

CHAR: [0-9a-zA-Z\u0080-\uFFFF]+;

WS: Ws+;

ANY: .;

// Tag
mode TAG;
GT: '>' -> popMode;
SLASH: '/';
EQUALS: '=';
TAG_NAME: [a-zA-Z]+;
STR_BEG: '"' -> pushMode(STR);
TAG_WS: Ws+ -> skip;

mode STR;
STR_END: '"' -> popMode;
STR_ESCAPED: Escaped;
STR_VAR_BEG: '${' -> pushMode(VAR);
STR_CHAR: [0-9a-zA-Z\u0080-\uFFFF]+;
STR_WS: Ws+;
STR_ANY: .;

mode VAR;
VAR_END: '}' -> popMode;
VAR_ESCAPED: Escaped;
VAR_NAME: [0-9a-zA-Z\-_\\.]+;
VAR_BAR: '|';
VAR_UNI: [\u0080-\uFFFF]+;
VAR_WS: Ws+;
VAR_ANY: .;

fragment Ws: [ \t\r\n];

// &amp; &lt; &gt; &quot; &dollar;
fragment Escaped: '&' [a-zA-Z]+ ';';

