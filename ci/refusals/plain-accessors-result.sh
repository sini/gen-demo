# shellcheck shell=bash
# ── row 70 -- a plain accessor's RESULT is refused BY NAME where gen-graph reads it
#    (gen-graph den-hoag-0mqv1; ADR-0025 item 1: a caller-supplied function owes a door per failure mode) ──
# `reachableFrom` and `topoOrder` apply the caller's `edges` and read each result as a list. A result
# that is not a list used to abort past `tryEval` ("expected a list but found an integer"), and an
# `edges` that is not a function aborted on its first application; both are now refused by the
# surface that read them. `leaves` compared the result with `[ ]` and answered a non-list as "not a
# leaf" at exit 0 -- the silent arm. The unplanted arm asserts the answers; the catchable arm is row
# 33's form.
row_plain_accessors_result='let
  genGraph = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.graph;
  lawful = id: { selvage = [ "warp" ]; warp = [ "weft" ]; }.${id} or [ ];
  graph = { nodes = [ "selvage" "warp" "weft" ]; edges = EDGES; };
  reached = genGraph.reachableFrom graph "selvage";
  ordered = genGraph.topoOrder { } graph;
  leaves = genGraph.leaves graph;
in BODY'
row_plain_accessors_resultok="${row_plain_accessors_result/EDGES/lawful}"
row_plain_accessors_resultint="${row_plain_accessors_result/EDGES/id: if id == \"warp\" then 1 else lawful id}"
row_plain_accessors_resultnf="${row_plain_accessors_result/EDGES/1}"
check "T5 plain-accessors-result unplanted (a lawful accessor; the answers are the assertion)" \
  "${row_plain_accessors_resultok/BODY/builtins.toJSON [ reached ordered.order leaves ]}" 0 "" \
  "$tmpdir/plain-accessors-result-green.err" '[["warp","weft"],["weft","warp","selvage"],["weft"]]'
check "T5 plain-accessors-result planted   (a non-list result, refused by name at reachableFrom)" \
  "${row_plain_accessors_resultint/BODY/builtins.toJSON reached}" 1 \
  'gen-graph.reachableFrom: edges "warp" returned a int, not a list of node ids' \
  "$tmpdir/plain-accessors-result-red-result.err"
check "T5 plain-accessors-result planted   (a non-list result, refused by name at leaves rather than answered)" \
  "${row_plain_accessors_resultint/BODY/builtins.toJSON leaves}" 1 \
  'gen-graph.leaves: edges "warp" returned a int, not a list of node ids' \
  "$tmpdir/plain-accessors-result-red-leaves.err"
check "T5 plain-accessors-result planted   (an edges that is not a function, refused by name at topoOrder)" \
  "${row_plain_accessors_resultnf/BODY/builtins.toJSON ordered}" 1 \
  "gen-graph.topoOrder: the accessor's edges is a int, not a function from a node id to a list of node ids" \
  "$tmpdir/plain-accessors-result-red-notfn.err"
check "T5 plain-accessors-result catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_plain_accessors_resultint/BODY/if (builtins.tryEval (builtins.deepSeq reached true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/plain-accessors-result-catch.err" 'CAUGHT'
