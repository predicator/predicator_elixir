Header
"%% Predicator Elixir".

Terminals lit load compare endcompare bang between 'or' '[' ']' ',' 'and'.

Nonterminals predicates predicate_group predicate variable array array_elements array_value.

Rootsymbol predicates.

predicates -> predicate_group : '$1'.
predicates -> bang predicate_group : lists:append('$2', [[<<"not">>]]).

predicate_group -> predicate : '$1'.
predicate_group -> predicate 'and' predicates : lists:append('$1', [jump(jfalse, '$3') | '$3']).
predicate_group -> predicate 'or' predicates : lists:append('$1', [jump(jtrue, '$3') | '$3']).

predicate -> lit : [unwrap('$1')].
predicate -> load : [unwrap('$1'), [<<"to_bool">>]].
predicate -> variable endcompare : ['$1', unwrap('$2')].
predicate -> variable compare variable : ['$1', '$3', unwrap('$2')].
predicate -> variable between lit 'and' lit : ['$1', unwrap('$3'), unwrap('$5'), unwrap('$2')].
predicate -> variable compare array : ['$1', [<<"array">>, '$3'], unwrap('$2')].

variable -> lit : unwrap('$1').
variable -> load : unwrap('$1').

array -> '[' array_elements ']' : '$2'.
array -> '[' ']' : [].

array_elements -> array_value ',' array_elements : ['$1' | '$3'].
array_elements -> array_value : ['$1'].

array_value -> lit : extract_value('$1').
array_value -> load : extract_value('$1').
array_value -> array : '$1'.


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
unwrap({_INST,_,V='BETWEEN'}) ->
  [tobin(compare), tobin(V)];
unwrap({INST,_,V='ENDS_WITH'}) ->
  [tobin(INST), tobin(V)];
unwrap({INST,_,V='true'}) ->
  [tobin(INST), V];
unwrap({INST,_,V='false'}) ->
  [tobin(INST), V];
unwrap({_INST,_,V=blank}) ->
  [tobin(V)];
unwrap({_INST,_,V=present}) ->
  [tobin(V)];
unwrap({INST,_,V}) when erlang:is_integer(V) ->
  [tobin(INST), V];
unwrap({INST,_,V}) ->
  [tobin(INST), tobin(V)].

tobin(ATOM) when erlang:is_atom(ATOM) ->
  erlang:atom_to_binary(ATOM, utf8);
tobin(STRING) when erlang:is_binary(STRING) ->
  STRING.

extract_value({_, _, V}) -> V.

jump(INST, Predicates) ->
  [tobin(INST), erlang:length(Predicates) + 1].