# shellcheck shell=bash
# ── row 106 -- a non-scalar edge target is refused BY NAME, catchably, at gen-graph's closure doors
#    (den-hoag-3w9e7, den-hoag-7gp66 OQ13 arm a; ADR-0025 item 1) ──
# `reachableFrom`, `canReach`, `selfReachable` and the hoisted `reachableVia`/`selfReachableVia` made
# every target an accessor returned a `genericClosure` key, and the closure's comparison of a set
# with a string aborted past `tryEval`. They now send every target through `identifier`, which
# refuses anything but a string by the door's name -- a set, list, function or null (den-hoag-3w9e7)
# and, since OQ13 closed the scalar residue (arm a, 2026-09-26: a node id is a string), an int, bool
# or float target too, the same way. The unplanted arm walks a string graph and asserts a STDOUT
# VALUE, so a door that refused everything cannot pass it. Every addressing is bound in the prelude:
# a `}` inside a `${row106/BODY/...}` replacement would end the expansion early.
row106='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genGraph = gen.lib.substrate.graph;
  g = t: { nodes = [ "a" "b" "c" ]; edges = id: if id == "a" then [ "b" ] else if id == "b" then [ t ] else [ ]; };
  green = builtins.concatStringsSep "," (genGraph.reachableFrom (g "c") "a");
  planted = genGraph.reachableFrom (g { }) "a";
  plantedInt = genGraph.reachableFrom (g 42) "a";
  red = builtins.deepSeq planted "admitted";
  redInt = builtins.deepSeq plantedInt "admitted";
  refused = v: !(builtins.tryEval (builtins.deepSeq v true)).success;
  caught = if refused planted && refused plantedInt then "CAUGHT" else "ADMITTED";
in BODY'
check "T5 row106 unplanted (a string target walks as before)" \
  "${row106/BODY/green}" 0 "" "$tmpdir/row106-green.err" 'b,c'
check "T5 row106 planted   (a set target is refused by the door's name)" \
  "${row106/BODY/red}" 1 \
  'gen-graph.reachableFrom: got set, expected a node identifier (a string)' "$tmpdir/row106-red.err"
check "T5 row106 planted   (an int target is refused by the door's name, den-hoag-7gp66 OQ13)" \
  "${row106/BODY/redInt}" 1 \
  'gen-graph.reachableFrom: got int, expected a node identifier (a string)' "$tmpdir/row106-red-int.err"
check "T5 row106 catchable  (both refusals are caught by tryEval, not an abort)" \
  "${row106/BODY/caught}" 0 "" "$tmpdir/row106-catch.err" 'CAUGHT'
