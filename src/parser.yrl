Nonterminals predicates predicate.


Terminals lit load comparator join.


Rootsymbol predicates.

predicates -> predicate : '$1'.
predicates -> predicate join predicate : ['$1', '$3'].
predicates -> predicates join predicate : {join, '$1', '$3'}.

predicate -> lit comparator load : [unwrap('$1'), unwrap('$2'), unwrap('$3')].
predicate -> load comparator lit : [unwrap('$1'), unwrap('$2'), unwrap('$3')].
predicate -> lit comparator lit : [unwrap('$1'), unwrap('$2'), unwrap('$3')].
predicate -> load comparator load : [unwrap('$1'), unwrap('$2'), unwrap('$3')].



Erlang code.

unwrap({INST,_,V}) -> [INST, V].
