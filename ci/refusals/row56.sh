# shellcheck shell=bash
# ── row 56 -- a labeled graph's accessor result is refused BY NAME where gen-graph reads it
#    (gen-graph vq94z; ADR-0025 item 1: a caller-supplied function owes a door per failure mode) ──
# A labeled graph is a structural record, so `labeledEdges` is a caller function and every surface
# applying it receives a value it did not build. The commonest forgery hands back bare TARGETS where
# edges `{ label; target; }` are owed; the walk used to read `.label` off a string and abort past
# `tryEval` ("expected a set but found a string"). It is now refused by the surface that applied the
# accessor: `query` directly, `boundedBy` when the graph was bounded first -- gen-view's own shape.
# The unplanted arm asserts the answer, and the catchable arm is row 33's form.
row56='let
  genGraph = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.graph;
  genuine = genGraph.labeledFrom {
    nodes = [ "pewter" "faille" "grosgrain" ];
    perLabel.tacks = id: { pewter = [ "faille" ]; faille = [ "grosgrain" ]; }.${id} or [ ];
  };
  lg = LG;
  reached = genGraph.query { graph = GRAPH; from = "pewter"; follow = genGraph.regex.star (genGraph.regex.lit "tacks"); };
in BODY'
row56plant='genuine // { labeledEdges = id: if id == "faille" then [ "grosgrain" ] else genuine.labeledEdges id; }'
row56unplanted="${row56/LG/genuine}"
row56unplanted="${row56unplanted/GRAPH/lg}"
row56planted="${row56/LG/$row56plant}"
row56direct="${row56planted/GRAPH/lg}"
row56bounded="${row56planted/GRAPH/genGraph.boundedBy lg (_: [ ])}"
check "T5 row56 unplanted (a genuine labeled graph; the answer is the assertion)" \
  "${row56unplanted/BODY/builtins.toJSON reached}" 0 "" \
  "$tmpdir/row56-green.err" '["faille","grosgrain","pewter"]'
check "T5 row56 planted   (bare targets for edges, refused by name at query)" \
  "${row56direct/BODY/builtins.toJSON reached}" 1 \
  'gen-graph.query: labeledEdges "faille" returned an element of type string, not an edge { label; target; }' \
  "$tmpdir/row56-red.err"
check "T5 row56 planted   (the same forgery bounded first, refused by the surface that applied it)" \
  "${row56bounded/BODY/builtins.toJSON reached}" 1 \
  'gen-graph.boundedBy: labeledEdges "faille" returned an element of type string, not an edge { label; target; }' \
  "$tmpdir/row56-bounded.err"
check "T5 row56 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row56direct/BODY/if (builtins.tryEval (builtins.deepSeq reached true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row56-catch.err" 'CAUGHT'
