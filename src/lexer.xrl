Definitions.

INTEGER    = [0-9]+
ATOM       = :[a-z_]+
WHITESPACE = [\s\t\n\r]

TRUE       = true
FALSE      = false
BETWEEN    = between
BANG       = [\!]
DOT        = .

IDENTIFIER = [a-z][A-Za-z0-9_]*
% STRING     = (["'])(?:\\?.)*?\1

Rules.


{Dot}          : skip_token.
{WHITESPACE}+  : skip_token.
{INT}          : {token, {int,  TokenLine, TokenChars}}.
{ATOM}         : {token, {atom, TokenLine, TokenChars}}.

{TRUE}         : {token, {'true', TokenLine, TokenChars}}.
{FALSE}        : {token, {'false', TokenLine, TokenChars}}.

{IDENTIFIER}   : {token, {'load', TokenLine, TokenChars}}.
\or            : {token, {'jump', TokenLine, TokenChars}}.
{AND}          : {token, {'union', TokenLine, TokenChars}}.

eq             : {token, {'comparator', TokenLine, TokenChars}}.
\==            : {token, {'comparator', TokenLine, TokenChars}}.
gt             : {token, {'comparator', TokenLine, TokenChars}}.
\>             : {token, {'comparator', TokenLine, TokenChars}}.
lt             : {token, {'comparator', TokenLine, TokenChars}}.
\<             : {token, {'comparator', TokenLine, TokenChars}}.
% ,              : {token, {',',  TokenLine, TokenChars}}.

Erlang code.

to_atom([$:|Chars]) ->
  list_to_atom(Chars).
