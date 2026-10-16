# `derivative-automaton-built-on-demand` — den-hoag-9z993 (ADR-0008, ADR-0032). gen-scope's
# `resolve` walks the product of the scope graph with the derivative automaton of the path
# expression, and unfolds that automaton as the walk reads it. `(a|b)* a (a|b)^20` has about 2^21
# derivative states; over the chain `r -a-> n1 -b-> n2 … -b-> n21` the word to n(j) is a b^(j−1),
# so the one answer is n21 and the walk visits 22 nodes. `(a b)*` from `x` over `x -a-> y -b-> x`
# returns to its own key after two letters and answers `x`; `(a b)* a` answers `y`.
#
# ★ THE RED IS NOT A VALUE: an eager construction would answer the same values after building
# every state, which does not finish, so it reds as a time-out or as the evaluator's call-depth
# limit, whichever it reaches first. A per-visit re-derivation passes this cell; that
# cost is gen-scope's bench (`resolve-visible-fanout`).
{ asserts, genScope }:
let
  scopeOf =
    ids: ea: eb:
    genScope.eval { parseParent = _: null; } {
      children = _: _: { };
      marks = _: _: [ ];
      edges-a = _: id: ea.${id} or [ ];
      edges-b = _: id: eb.${id} or [ ];
    } (genScope.buildRoots { parentGraph = genScope.vertices ids; });
  walk =
    expression: g: from:
    map (a: a.node)
      (genScope.resolve {
        wf = genScope.wellFormed {
          alphabet = [
            "a"
            "b"
          ];
          inherit expression;
        };
        dataFilter = _: true;
      } g from).answers;
  n = j: "n${toString j}";
  chain = scopeOf ([ "r" ] ++ builtins.genList (j: n (j + 1)) 21) { r = [ (n 1) ]; } (
    builtins.listToAttrs (
      builtins.genList (j: {
        name = n (j + 1);
        value = [ (n (j + 2)) ];
      }) 20
    )
  );
  cycle = scopeOf [
    "x"
    "y"
  ] { x = [ "y" ]; } { y = [ "x" ]; };
in
{
  construct = [ "derivative-automaton-built-on-demand" ];
  check = asserts (
    walk ("(a|b)*a" + builtins.concatStringsSep "" (builtins.genList (_: "(a|b)") 20)) chain "r" == [
      "n21"
    ]
    && walk "(a b)*" cycle "x" == [ "x" ]
    && walk "(a b)* a" cycle "x" == [ "y" ]
  );
}
