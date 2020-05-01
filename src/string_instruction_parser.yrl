Header
"%% Predicator Elixir".

Terminals lit load comparator jfalse jtrue '[' ']' ',' '&'.

Nonterminals predicates predicate value array array_elements.

Rootsymbol predicates.

predicates -> predicate : '$1'.
predicates -> predicate jfalse predicate : ['$1', jfalse, '$3']. %% jfalse
predicates -> predicates jfalse predicate : {'$1', jfalse, '$3'}.
predicates -> predicate jtrue predicate : ['$1', jtrue, '$3']. %% jtrue
predicates -> predicates jtrue predicate : {'$1', jtrue, '$3'}.

predicate -> lit comparator load : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> load comparator lit : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> lit comparator lit : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> load comparator load : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> load comparator array : [unwrap('$1'), [list, '$3'], unwrap('$2')].
predicate -> load comparator lit '&' lit : [unwrap('$1'), unwrap('$3'), unwrap('$5'), unwrap('$2')].

value -> lit : extract_value('$1').
value -> load : extract_value('$1').
value -> array : '$1'.
array -> '[' array_elements ']' : '$2'.
array -> '[' ']' : [].
array_elements ->
  value ',' array_elements : ['$1' | '$3'].
array_elements ->
  value : ['$1'].

Erlang code.

unwrap({INST,_,V='GT'}) ->
  [tobin(INST), tobin(V)];
unwrap({INST,_,V='LT'}) ->
  [tobin(INST), tobin(V)];
unwrap({INST,_,V='EQ'}) ->
  [tobin(INST), tobin(V)];
unwrap({INST,_,V='IN'}) ->
  [tobin(INST), tobin(V)];
unwrap({INST,_,V='NOTIN'}) ->
  [tobin(INST), tobin(V)];
unwrap({INST,_,V='BETWEEN'}) ->
  [tobin(INST), tobin(V)];
unwrap({INST,_,V}) ->
  [tobin(INST), V].

tobin(ATOM) -> erlang:atom_to_binary(ATOM, utf8).

extract_value({_, _, V}) -> V.
