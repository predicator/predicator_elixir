Nonterminals.
predicates predicate list element elements.

Terminals.
int atom true false lit load jump union comparator.

Rootsymbol predicates.
predicates -> predicate : '$1'.
predicates -> predicate union predicate : {union, '$1', '$3'}.
predicates -> predicates union predicate : {union, '$1', '$3'}.

predicate -> lit

Rules.


Erlang code.
