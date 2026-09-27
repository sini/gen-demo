# shellcheck shell=bash
# ── row 104 -- gen-graph's keying doors refuse a non-string node identifier BY NAME, catchably
#    (ADR-0025 item 1) ──
# A door that keys an attrset by the identifiers a caller's `edges` returns used to abort past
# `tryEval` with interpreter text (`expected a string but found an integer`) when an edge target
# was not a string. The refusal now names the published door the caller invoked. The unplanted arm
# runs the same graph with a string target and asserts a STDOUT VALUE, so a door that refused
# everything cannot pass it. Every addressing is bound in the prelude: a `}` inside a
# `${row104/BODY/...}` replacement would end the expansion early.
row104='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  graph = gen.lib.substrate.graph;
  g = t: { nodes = [ "a" "b" ]; edges = id: if id == "a" then [ t ] else [ ]; };
  bad = graph.directDependents (g 1);
  green = builtins.toJSON (graph.directDependents (g "b"));
  red = builtins.toJSON bad;
  caught = if (builtins.tryEval (builtins.deepSeq bad null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row104 unplanted (a string edge target answers)" \
  "${row104/BODY/green}" 0 "" "$tmpdir/row104-green.err" '{"b":["a"]}'
check "T5 row104 planted   (an int edge target is refused by name)" \
  "${row104/BODY/red}" 1 \
  "gen-graph.directDependents: got int, expected a node identifier (a string)" "$tmpdir/row104-red.err"
check "T5 row104 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row104/BODY/caught}" 0 "" "$tmpdir/row104-catch.err" 'CAUGHT'
