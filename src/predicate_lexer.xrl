Definitions.

WHITESPACE   = [\s\t\n\r]
EQUAL        = (==|=|===|equal)
LESS_THAN    = (less_than|lt|LT|<)
GREATER_THAN = (greater_than|gt|GT|>)
BETWEEN      = (between|bt|BTWEEN|BT|\.\.)
IN           = (in|IN|IN)
NOTIN        = (notin|NOTIN|NI|not\s\in)
STARTS_WITH  = (starts_with|STARTS_WITH|SW|starts\swith|startswith)
ENDS_WITH    = (ends_with|ENDS_WITH|EW|ends\swith|endswith)
BLANK        = (is_blank|IS_BLANK|IB|is\sblank|isblank)
PRESENT      = (is_present|IS_PRESENT|IP|is\spresent|ispresent)
AND          = (and|AND|&)
OR           = (or|OR)
ATOM         = :[a-z_]+
IDENTIFIER   = [a-z][A-Za-z0-9_]*
INTEGER      = [0-9]+
SYMBOLS      = [{}\[\],]
STRING       = ("((\?:\\.|[^\\""])*)"|'((\?:\\.|[^\\''])*)')
BOOLEAN      = (true|false)


Rules.

{GREATER_THAN} : {token, {comparator, TokenLine, 'GT'}}.
{LESS_THAN}    : {token, {comparator, TokenLine, 'LT'}}.
{EQUAL}        : {token, {comparator, TokenLine, 'EQ'}}.
{BETWEEN}      : {token, {comparator, TokenLine, 'BETWEEN'}}.
{IN}           : {token, {comparator, TokenLine, 'IN'}}.
{NOTIN}        : {token, {comparator, TokenLine, 'NOTIN'}}.
{STARTS_WITH}  : {token, {comparator, TokenLine, 'STARTSWITH'}}.
{ENDS_WITH}    : {token, {comparator, TokenLine, 'ENDSWITH'}}.
{BLANK}        : {token, {endcomparator, TokenLine, blank}}.
{PRESENT}      : {token, {endcomparator, TokenLine, present}}.
{AND}          : {token, {'&', TokenLine}}.
{OR}           : {token, {jtrue, TokenLine}}.
{BOOLEAN}      : {token, {lit, TokenLine, list_to_existing_atom(TokenChars)}}.
{INTEGER}      : {token, {lit, TokenLine, list_to_integer(TokenChars)}}.
{STRING}       : {token, {lit, TokenLine, sanitized_string(TokenChars)}}.
{ATOM}         : {token, {load, TokenLine, list_to_atom(TokenChars)}}.
{IDENTIFIER}   : {token, {load, TokenLine, list_to_atom(TokenChars)}}.
{SYMBOLS}      : {token, {list_to_atom(TokenChars), TokenLine}}.
{WHITESPACE}   : skip_token.
% and            : {token, {jfalse, TokenLine, list_to_existing_atom(TokenChars)}}.
% or             : {token, {jtrue, TokenLine, list_to_existing_atom(TokenChars)}}.


Erlang code.
sanitized_string("'" ++ _Rest = Str) ->
  string:trim(list_to_binary(Str), both, "'");
sanitized_string(Str) ->
  string:trim(list_to_binary(Str), both, "\"").
