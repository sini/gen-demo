# shellcheck shell=bash
# ── row 56 -- an evaluated scope's edge attribute result is refused BY NAME where the calculus reads it
#    (gen-graph vq94z, carried to gen-scope's `resolve` by den-hoag-gayc; ADR-0025 item 1: a
#    caller-supplied function owes a door per failure mode) ──
# An edge attribute `edges-l` is a caller function, and the walk receives a value it did not build.
# The commonest forgery hands back EDGES `{ label; target; }` where node ids are owed (the labelled
# record's shape, in the scope's slot); the walk would read a set as a node id. It is refused by the
# calculus at the read, naming the node and the letter -- directly, and under a `bound` narrowing
# (gen-view's own bounded shape). The unplanted arm asserts the answer, and the catchable arm is row
# 33's form. Every node declares its marks, none.
row56='let
  s = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.scope;
  tacks = { pewter = [ "faille" ]; faille = [ "grosgrain" ]; };
  genuine = id: tacks.${id} or [ ];
  edgesTacks = EDGES;
  scope = s.eval { parseParent = _: null; } {
    children = _: _: { };
    marks = _: _: [ ];
    edges-tacks = _: edgesTacks;
  } (s.buildRoots { parentGraph = s.vertices [ "pewter" "faille" "grosgrain" ]; });
  reached = builtins.sort builtins.lessThan (map (a: a.node) (s.resolve ({
    wf = s.wellFormed { alphabet = [ "tacks" ]; expression = s.wfl.star (s.wfl.lit "tacks"); };
    dataFilter = _: true;
  } // BOUND) scope "pewter").answers);
in BODY'
row56plant='id: if id == "faille" then [ { label = "tacks"; target = "grosgrain"; } ] else genuine id'
row56unplanted="${row56/EDGES/genuine}"
row56unplanted="${row56unplanted/BOUND/{ \}}"
row56planted="${row56/EDGES/$row56plant}"
row56direct="${row56planted/BOUND/{ \}}"
row56bounded="${row56planted/BOUND/{ bound = _: [ ]; \}}"
check "T5 row56 unplanted (a genuine edge attribute; the answer is the assertion)" \
  "${row56unplanted/BODY/builtins.toJSON reached}" 0 "" \
  "$tmpdir/row56-green.err" '["faille","grosgrain","pewter"]'
check "T5 row56 planted   (edges for node ids, refused by name at resolve)" \
  "${row56direct/BODY/builtins.toJSON reached}" 1 \
  "gen-scope.resolve: node \"faille\", letter 'tacks': an edge target is a set, not a node id (a string)" \
  "$tmpdir/row56-red.err"
check "T5 row56 planted   (the same forgery under a bound, refused by the same read)" \
  "${row56bounded/BODY/builtins.toJSON reached}" 1 \
  "gen-scope.resolve: node \"faille\", letter 'tacks': an edge target is a set, not a node id (a string)" \
  "$tmpdir/row56-bounded.err"
check "T5 row56 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row56direct/BODY/if (builtins.tryEval (builtins.deepSeq reached true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row56-catch.err" 'CAUGHT'
