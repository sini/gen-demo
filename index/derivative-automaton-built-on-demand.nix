{
  title = "the derivative automaton, built on demand";
  adr = "0008, 0032 (den-hoag-9z993)";
  what = "`derivative-automaton-built-on-demand`: gen-scope's `resolve` in mode `reachable` over a chain under `(a|b)* a (a|b)^20`, whose derivative automaton has about 2^21 states while the walk visits 22, answers the one node the word reaches; `(a b)*` and `(a b)* a` over a two-node cycle answer `x` and `y`. The automaton is unfolded as the walk reads it, so an eager construction does not finish here (the red is a time-out or the evaluator's call-depth limit, not a value)";
}
