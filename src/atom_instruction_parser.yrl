Header
"%% Predicator Elixir".

Terminals lit load comparator jfalse jtrue '[' ']' ',' '&' string blank. 

Nonterminals predicates predicate value array array_elements.

Rootsymbol predicates.

predicates -> predicate : '$1'.
predicates -> predicate jfalse predicate : ['$1', jfalse, '$3']. %% jfalse
predicates -> predicates jfalse predicate : {'$1', jfalse, '$3'}.
predicates -> predicate jtrue predicate : ['$1', jtrue, '$3']. %% jtrue
predicates -> predicates jtrue predicate : {'$1', jtrue, '$3'}.

predicate -> load blank : [unwrap('$1'), unwrap('$2')].
predicate -> lit blank : [unwrap('$1'), unwrap('$2')].
predicate -> string blank : [unwrap_string('$1'), unwrap('$2')].
predicate -> lit comparator load : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> load comparator lit : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> lit comparator lit : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> load comparator load : [unwrap('$1'), unwrap('$3'), unwrap('$2')].
predicate -> load comparator lit '&' lit : [unwrap('$1'), unwrap('$3'), unwrap('$5'), unwrap('$2')].
predicate -> lit comparator lit '&' lit : [unwrap('$1'), unwrap('$3'), unwrap('$5'), unwrap('$2')].
predicate -> load comparator array : [unwrap('$1'), [array, '$3'], unwrap('$2')].
predicate -> lit comparator array : [unwrap('$1'), [array, '$3'], unwrap('$2')].
predicate -> string comparator string : [unwrap_string('$1'), unwrap_string('$3'), unwrap('$2')].
predicate -> load comparator string : [unwrap('$1'), unwrap_string('$3'), unwrap('$2')].

array -> '[' array_elements ']' : '$2'.
array -> '[' ']' : [].

array_elements -> value ',' array_elements : ['$1' | '$3'].
array_elements -> value : ['$1'].

value -> lit : extract_value('$1').
value -> load : extract_value('$1').
value -> array : '$1'.


Erlang code.

unwrap({INST,_,V}) -> [INST, V];
unwrap({INST, _}) -> [INST].

unwrap_string({_INST=string,V, _}) -> [lit, V].
extract_value({_, _, V}) -> V.
