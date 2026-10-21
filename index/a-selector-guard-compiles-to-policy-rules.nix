{
  title = "a selector guard compiles to policy rules";
  adr = "0019, 0020";
  what = "`a-selector-guard-compiles-to-policy-rules`: C5's piping guard written as a gen-select selector, `and [ nap:pewter (not scotched:pewter) ]`, compiles through `adapters.program.bodies` to exactly C5's own literals; a disjunctive guard and its negation over C5's frozen relata each compile to one declaration per disjunct, and the solved head is `included` exactly where `matches` decides the selector true";
}
