Header
"%% Predicator Elixir".

Terminals lit load comparator endcomparator between 'or' '[' ']' ',' 'and'. 

Nonterminals predicates predicate value array array_elements.

Rootsymbol predicates.

predicates -> predicate : '$1'.
predicates -> predicate 'and' predicates : lists:append('$1', [jump(jfalse, '$3') | '$3']).
predicates -> predicate 'or' predicates : lists:append('$1', [jump(jtrue, '$3') | '$3']).

predicate -> load endcomparator : [unwrap('$1'), unwrap('$2')].
predicate -> lit endcomparator : [unwrap('$1'), unwrap('$2')].
predicate -> lit comparator load : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> load comparator lit : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> lit comparator lit : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> load comparator load : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> load between lit 'and' lit : [unwrap('$1'), unwrap('$3'), unwrap('$5'), unwrap('$2')].
predicate -> lit between lit 'and' lit : [unwrap('$1'), unwrap('$3'), unwrap('$5'), unwrap('$2')].
predicate -> load comparator array : [unwrap('$1'), [array, '$3'], unwrap('$2')].
predicate -> lit comparator array : [unwrap('$1'), [array, '$3'], unwrap('$2')].

array -> '[' array_elements ']' : '$2'.
array -> '[' ']' : [].

array_elements -> value ',' array_elements : ['$1' | '$3'].
array_elements -> value : ['$1'].

value -> lit : extract_value('$1').
value -> load : extract_value('$1').
value -> array : '$1'.

Erlang code.

unwrap({_INST,_,V=blank}) -> [V];
unwrap({_INST,_,V=present}) -> [V];
unwrap({between,_,V}) -> [comparator, V];
unwrap({INST,_,V}) -> [INST, V].

extract_value({_, _, V}) -> V.

jump(INST, Predicates) ->
  [INST, erlang:length(Predicates) + 1].
