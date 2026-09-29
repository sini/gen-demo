# ── C101 — AN OUTPUTS TERMINAL OVER A CONSUMER'S OWN EVALUATE (ADR-0027, ADR-0031) ──
# (den-hoag-52hn7). gen-bind's `crossing.mkOutputsTerminal evaluate` names no module system: the
# consumer hands it the `evaluate` that turns a Body into outputs, and the terminal is a
# null-position Adapter over it. This construct's `evaluate` is framework-free on purpose — a fold
# of attrsets — so the reading is of the terminal's own contract, not of any evaluator behind it.
{ genBind }:
let
  tasselBody = [
    { tassel = 1; }
    { fringe = 2; }
  ];
  tasselEvaluate = body: builtins.foldl' (acc: m: acc // m) { } body;
  tasselTerminal = genBind.crossing.mkOutputsTerminal tasselEvaluate;
in
{
  inherit
    tasselBody
    tasselEvaluate
    tasselTerminal
    ;
}
