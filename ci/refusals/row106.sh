# shellcheck shell=bash
# ── row 106 -- a non-scalar edge target is refused BY NAME, catchably, at gen-graph's closure doors
#    (den-hoag-3w9e7; ADR-0025 item 1) ──
# `reachableFrom`, `canReach`, `selfReachable` and the hoisted `reachableVia`/`selfReachableVia` made
# every target an accessor returned a `genericClosure` key, and the closure's comparison of a set
# with a string aborted past `tryEval`. They now send a non-string target through `nodeKey`, which
# refuses a set, list, function or null by the door's name. The unplanted arm walks a string graph
# and asserts a STDOUT VALUE, so a door that refused everything cannot pass it. An int target still
# aborts pending den-hoag-7gp66 OQ13; gen-graph pins that residue, not this row. Every addressing is
# bound in the prelude: a `}` inside a `${row106/BODY/...}` replacement would end the expansion early.
row106='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genGraph = gen.lib.substrate.graph;
  g = t: { nodes = [ "a" "b" "c" ]; edges = id: if id == "a" then [ "b" ] else if id == "b" then [ t ] else [ ]; };
  green = builtins.concatStringsSep "," (genGraph.reachableFrom (g "c") "a");
  planted = genGraph.reachableFrom (g { }) "a";
  red = builtins.deepSeq planted "admitted";
  caught = if (builtins.tryEval (builtins.deepSeq planted true)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row106 unplanted (a string target walks as before)" \
  "${row106/BODY/green}" 0 "" "$tmpdir/row106-green.err" 'b,c'
check "T5 row106 planted   (a set target is refused by the door's name)" \
  "${row106/BODY/red}" 1 \
  'gen-graph.reachableFrom: got set, expected a node identifier (a string or another scalar)' "$tmpdir/row106-red.err"
check "T5 row106 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row106/BODY/caught}" 0 "" "$tmpdir/row106-catch.err" 'CAUGHT'
