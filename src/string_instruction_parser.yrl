Header
"%% Predicator Elixir".

Terminals lit load comparator endcomparator jfalse jtrue '[' ']' ',' '&' string.

Nonterminals predicates predicate value array array_elements.

Rootsymbol predicates.

predicates -> predicate : '$1'.
% predicates -> predicate jfalse predicate : ['$1', jfalse, '$3']. %% jfalse
% predicates -> predicates jfalse predicate : {'$1', jfalse, '$3'}.
% predicates -> predicate jtrue predicate : ['$1', jtrue, '$3']. %% jtrue
% predicates -> predicates jtrue predicate : {'$1', jtrue, '$3'}.
predicates -> predicate jtrue predicates : lists:append('$1', [jump(jtrue, '$3') | '$3']).

predicate -> load endcomparator : [unwrap('$1'), unwrap('$2')].
predicate -> lit endcomparator : [unwrap('$1'), unwrap('$2')].
predicate -> string endcomparator : [unwrap_string('$1'), unwrap('$2')].
predicate -> lit comparator load : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> load comparator lit : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> lit comparator lit : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> load comparator load : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> load comparator lit '&' lit : [unwrap('$1'), unwrap('$3'), unwrap('$5'), unwrap('$2')].
predicate -> lit comparator lit '&' lit : [unwrap('$1'), unwrap('$3'), unwrap('$5'), unwrap('$2')].
predicate -> load comparator array : [unwrap('$1'), [<<"array">>, '$3'], unwrap('$2')].
predicate -> lit comparator array : [unwrap('$1'), [<<"array">>, '$3'], unwrap('$2')].
predicate -> string comparator array : [unwrap_string('$1'), [<<"array">>, '$3'], unwrap('$2')].
predicate -> string comparator string : [unwrap_string('$1'), unwrap_string('$3'), unwrap('$2')].
predicate -> load comparator string : [unwrap('$1'), unwrap_string('$3'), unwrap('$2')].

array -> '[' array_elements ']' : '$2'.
array -> '[' ']' : [].

array_elements -> value ',' array_elements : ['$1' | '$3'].
array_elements -> value : ['$1'].

value -> lit : extract_value('$1').
value -> load : extract_value('$1').
value -> string : extract_string('$1').
value -> array : '$1'.

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
unwrap({INST,_,V='ENDS_WITH'}) ->
  [tobin(INST), tobin(V)];
unwrap({_INST,_,V=blank}) ->
  [tobin(V)];
unwrap({_INST,_,V=present}) ->
  [tobin(V)];
unwrap({INST,_,V}) when erlang:is_integer(V) ->
  [tobin(INST), V];
unwrap({INST,_,V}) ->
  [tobin(INST), tobin(V)].

unwrap_string({_INST=string,V, _}) -> [<<"lit">>, V].

tobin(ATOM) -> erlang:atom_to_binary(ATOM, utf8).

extract_string({_, Str, _}) -> Str.

extract_value({_, _, V}) -> V.

jump(INST=jtrue, Predicates) ->
  [tobin(INST), erlang:length(Predicates) + 1].