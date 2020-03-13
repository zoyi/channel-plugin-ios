grammar UserChatSearch;

start: expression? (WS+ expression)* WS* EOF;

expression: after | before | category | userChatState | assignee | hashtag | text;

after: AFTER date;
before: BEFORE date;

category: CATEGORY str;

userChatState: STATE str;

assignee: ASSIGNEE AT str;

hashtag: SHARP str;

text: str;

date: DIGIT DIGIT DIGIT DIGIT DASH DIGIT DIGIT DASH DIGIT DIGIT;

str: (ANY | DIGIT | AFTER | BEFORE | CATEGORY | STATE | ASSIGNEE | AT | SHARP | DASH)+;

DIGIT: [0-9];

AFTER: 'after:';

BEFORE: 'before:';

CATEGORY: 'category:';

STATE: 'state:';

ASSIGNEE: 'assignee:';

AT: '@';

SHARP: '#';

DASH: '-';

WS: ' ';

ANY: .;
