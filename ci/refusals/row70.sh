# shellcheck shell=bash
# ── row 70 -- a plain accessor's RESULT is refused BY NAME where gen-graph reads it
#    (gen-graph den-hoag-0mqv1; ADR-0025 item 1: a caller-supplied function owes a door per failure mode) ──
# `reachableFrom` and `topoOrder` apply the caller's `edges` and read each result as a list. A result
# that is not a list used to abort past `tryEval` ("expected a list but found an integer"), and an
# `edges` that is not a function aborted on its first application; both are now refused by the
# surface that read them. `leaves` compared the result with `[ ]` and answered a non-list as "not a
# leaf" at exit 0 -- the silent arm. The unplanted arm asserts the answers; the catchable arm is row
# 33's form.
row70='let
  genGraph = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.graph;
  lawful = id: { selvage = [ "warp" ]; warp = [ "weft" ]; }.${id} or [ ];
  graph = { nodes = [ "selvage" "warp" "weft" ]; edges = EDGES; };
  reached = genGraph.reachableFrom graph "selvage";
  ordered = genGraph.topoOrder { } graph;
  leaves = genGraph.leaves graph;
in BODY'
row70ok="${row70/EDGES/lawful}"
row70int="${row70/EDGES/id: if id == \"warp\" then 1 else lawful id}"
row70nf="${row70/EDGES/1}"
check "T5 row70 unplanted (a lawful accessor; the answers are the assertion)" \
  "${row70ok/BODY/builtins.toJSON [ reached ordered.order leaves ]}" 0 "" \
  "$tmpdir/row70-green.err" '[["warp","weft"],["weft","warp","selvage"],["weft"]]'
check "T5 row70 planted   (a non-list result, refused by name at reachableFrom)" \
  "${row70int/BODY/builtins.toJSON reached}" 1 \
  'gen-graph.reachableFrom: edges "warp" returned a int, not a list of node ids' \
  "$tmpdir/row70-red-result.err"
check "T5 row70 planted   (a non-list result, refused by name at leaves rather than answered)" \
  "${row70int/BODY/builtins.toJSON leaves}" 1 \
  'gen-graph.leaves: edges "warp" returned a int, not a list of node ids' \
  "$tmpdir/row70-red-leaves.err"
check "T5 row70 planted   (an edges that is not a function, refused by name at topoOrder)" \
  "${row70nf/BODY/builtins.toJSON ordered}" 1 \
  "gen-graph.topoOrder: the accessor's edges is a int, not a function from a node id to a list of node ids" \
  "$tmpdir/row70-red-notfn.err"
check "T5 row70 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row70int/BODY/if (builtins.tryEval (builtins.deepSeq reached true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row70-catch.err" 'CAUGHT'
