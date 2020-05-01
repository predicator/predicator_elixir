Definitions.

WHITESPACE   = [\s\t\n\r]
EQUAL        = (==|=|===|equal)
LESS_THAN    = (less_than|lt|LT|<)
GREATER_THAN = (greater_than|gt|GT|>)
BETWEEN      = (between|bt|BTWEEN|BT|\.\.)
IN           = (in|IN|IN)
NOTIN        = (notin|NOTIN|NI|not\s\in)
STARTS_WITH  = (starts_with|STARTS_WITH|SW)
ENDS_WITH    = (ends_with|ENDS_WITH|EW)
AND          = (and|AND|&)

ATOM         = :[a-z_]+
IDENTIFIER   = [a-z][A-Za-z0-9_]*
INTEGER      = [0-9]+
SYMBOLS      = [{}\[\],]
% ARRAY        = \[(.*?)\]
BOOLEAN      = (true|false)


Rules.

{GREATER_THAN} : {token, {comparator, TokenLine, 'GT'}}.
{LESS_THAN}    : {token, {comparator, TokenLine, 'LT'}}.
{EQUAL}        : {token, {comparator, TokenLine, 'EQ'}}.
{BETWEEN}      : {token, {comparator, TokenLine, 'BETWEEN'}}.
{IN}           : {token, {comparator, TokenLine, 'IN'}}.
{NOTIN}        : {token, {comparator, TokenLine, 'NOTIN'}}.
{STARTS_WITH}  : {token, {comparator, TokenLine, 'STARTS_WITH'}}.
{ENDS_WITH}    : {token, {comparator, TokenLine, 'ENDS_WITH'}}.
{AND}          : {token, {'&', TokenLine}}.
% {AND}          : skip_token.
{BOOLEAN}      : {token, {lit, TokenLine, list_to_existing_atom(TokenChars)}}.
{INTEGER}      : {token, {lit, TokenLine, list_to_integer(TokenChars)}}.
{ATOM}         : {token, {load, TokenLine, list_to_atom(TokenChars)}}.
{IDENTIFIER}   : {token, {load, TokenLine, list_to_atom(TokenChars)}}.
{WHITESPACE}   : skip_token.
{SYMBOLS}      : {token, {list_to_atom(TokenChars), TokenLine}}.
% and            : {token, {jfalse, TokenLine, list_to_existing_atom(TokenChars)}}.
% or             : {token, {jtrue, TokenLine, list_to_existing_atom(TokenChars)}}.


Erlang code.
