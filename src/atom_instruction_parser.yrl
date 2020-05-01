Header
"%% Predicator Elixir".

Terminals lit load comparator jfalse jtrue '[' ']' ',' '&'.

Nonterminals predicates predicate value array array_elements between.

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

array_elements -> value ',' array_elements : ['$1' | '$3'].
array_elements -> value : ['$1'].


Erlang code.

unwrap({INST,_,V}) -> [INST, V].
extract_value({_, _, V}) -> V.
