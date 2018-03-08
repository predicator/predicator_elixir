Header
"%% Predicator Elixir".

Nonterminals predicates predicate.

Terminals lit load comparator jfalse jtrue.

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

Erlang code.

unwrap({INST,_,V}) -> [INST, V].
