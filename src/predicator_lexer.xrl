Definitions.

WHITESPACE   = [\s\t\n\r]

EQUAL        = (==|=|===|equal)
LESS_THAN    = (lt|LT|<)
GREATER_THAN = (gt|GT|>)

ATOM         = :[a-z_]+
IDENTIFIER   = [a-z][A-Za-z0-9_]*
INTEGER      = [0-9]+
BOOLEAN      = (true|false)


Rules.

{WHITESPACE}   : skip_token.

{GREATER_THAN} : {token, {comparator, TokenLine, 'GT'}}.
{LESS_THAN}    : {token, {comparator, TokenLine, 'LT'}}.
{EQUAL}        : {token, {comparator, TokenLine, 'EQ'}}.

and            : {token, {jfalse, TokenLine, list_to_existing_atom(TokenChars)}}.
or             : {token, {jtrue, TokenLine, list_to_existing_atom(TokenChars)}}.

{BOOLEAN}      : {token, {lit, TokenLine, list_to_existing_atom(TokenChars)}}.
{ATOM}         : {token, {load, TokenLine, list_to_atom(TokenChars)}}.
{IDENTIFIER}   : {token, {load, TokenLine, list_to_atom(TokenChars)}}.
{INTEGER}      : {token, {lit, TokenLine, list_to_integer(TokenChars)}}.


Erlang code.



% [["load", "age"], ["lit", 21],  ["compare", "GT"],   ["jfalse", 4], ["lit", 14], ["lit", 234], ["compare", "LT"]]
% [[:load, 'this'], [:lit, true], [:comparator, :EQ]], :jfalse,       [[:lit, 14], [:lit, 234],  [:comparator, :LT]]
