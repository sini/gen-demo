# shellcheck shell=bash
# ── row 104 -- gen-graph's keying doors refuse a non-string node identifier BY NAME, catchably
#    (ADR-0025 item 1) ──
# A door that keys an attrset by the identifiers a caller's `edges` returns used to abort past
# `tryEval` with interpreter text (`expected a string but found an integer`) when an edge target
# was not a string. The refusal now names the published door the caller invoked. The unplanted arm
# runs the same graph with a string target and asserts a STDOUT VALUE, so a door that refused
# everything cannot pass it. Every addressing is bound in the prelude: a `}` inside a
# `${row104/BODY/...}` replacement would end the expansion early.
row_gen_graphs_keying_doors_refuse_a_non_string_node_identifier_by_name='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  graph = gen.lib.substrate.graph;
  g = t: { nodes = [ "a" "b" ]; edges = id: if id == "a" then [ t ] else [ ]; };
  bad = graph.directDependents (g 1);
  green = builtins.toJSON (graph.directDependents (g "b"));
  red = builtins.toJSON bad;
  caught = if (builtins.tryEval (builtins.deepSeq bad null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 gen-graphs-keying-doors-refuse-a-non-string-node-identifier-by-name unplanted (a string edge target answers)" \
  "${row_gen_graphs_keying_doors_refuse_a_non_string_node_identifier_by_name/BODY/green}" 0 "" "$tmpdir/gen-graphs-keying-doors-refuse-a-non-string-node-identifier-by-name-green.err" '{"b":["a"]}'
check "T5 gen-graphs-keying-doors-refuse-a-non-string-node-identifier-by-name planted   (an int edge target is refused by name)" \
  "${row_gen_graphs_keying_doors_refuse_a_non_string_node_identifier_by_name/BODY/red}" 1 \
  "gen-graph.directDependents: got int, expected a node identifier (a string)" "$tmpdir/gen-graphs-keying-doors-refuse-a-non-string-node-identifier-by-name-red.err"
check "T5 gen-graphs-keying-doors-refuse-a-non-string-node-identifier-by-name catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_gen_graphs_keying_doors_refuse_a_non_string_node_identifier_by_name/BODY/caught}" 0 "" "$tmpdir/gen-graphs-keying-doors-refuse-a-non-string-node-identifier-by-name-catch.err" 'CAUGHT'
