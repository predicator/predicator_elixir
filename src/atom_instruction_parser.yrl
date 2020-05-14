Header
"%% Predicator Elixir".

Terminals lit load comparator endcomparator bang between 'or' '[' ']' ',' 'and'. 

Nonterminals predicates predicate_group predicate variable array array_elements array_value.

Rootsymbol predicates.

predicates -> predicate_group : '$1'.
predicates -> bang predicate_group : lists:append('$2', [['not']]).

predicate_group -> predicate : '$1'.
predicate_group -> predicate 'and' predicates : lists:append('$1', [jump(jfalse, '$3') | '$3']).
predicate_group -> predicate 'or' predicates : lists:append('$1', [jump(jtrue, '$3') | '$3']).

predicate -> lit : [unwrap('$1')].
predicate -> load : [unwrap('$1'), [to_bool]].
predicate -> variable endcomparator : ['$1', unwrap('$2')].
predicate -> variable comparator variable : ['$1', '$3', unwrap('$2')].
predicate -> variable between lit 'and' lit : ['$1', unwrap('$3'), unwrap('$5'), unwrap('$2')].
predicate -> variable comparator array : ['$1', [array, '$3'], unwrap('$2')].

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

unwrap({_INST,_,V=blank}) -> [V];
unwrap({_INST,_,V=present}) -> [V];
unwrap({between,_,V}) -> [comparator, V];
unwrap({INST,_,V}) -> [INST, V].

extract_value({_, _, V}) -> V.

jump(INST, Predicates) ->
  [INST, erlang:length(Predicates) + 1].
