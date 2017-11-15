Definitions.

INTEGER    = [0-9]+
ATOM       = :[a-z_]+
WHITESPACE = [\s\t\n\r]

% COMPARATOR = (<|<=|=|>=|>)
IDENTIFIER   = [a-z][A-Za-z0-9_]*
GREATER_THAN = (gt|GT|>)
LESS_THAN    = (lt|LT|<)
EQUAL        = (==|=|===|equal)

Rules.

{WHITESPACE}   : skip_token.
not            : {token, {}}
and            : {token, {join, TokenLine, list_to_atom(TokenChars)}}.
true           : {token, {lit, TokenLine, list_to_existing_atom(TokenChars)}}.
false          : {token, {lit, TokenLine, list_to_existing_atom(TokenChars)}}.
{GREATER_THAN} : {token, {comparator, TokenLine, 'GT'}}.
{LESS_THAN}    : {token, {comparator, TokenLine, 'LT'}}.
{EQUAL}        : {token, {comparator, TokenLine, 'EQ'}}.
{INTEGER}      : {token, {lit, TokenLine, list_to_integer(TokenChars)}}.
{IDENTIFIER}   : {token, {load, TokenLine, TokenChars}}.


Erlang code.
