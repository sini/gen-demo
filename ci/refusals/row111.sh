# shellcheck shell=bash
# ── row 111 -- a primitive's refusal reached through gen-graph's `cycles` door names the DOOR,
#    catchably (den-hoag-7gp66 P1, R6 "a primitive refusal naming the door"; ADR-0025 item 1) ──
# `cycles` reaches the shared `lowlink` primitive, whose list check refuses an accessor whose
# `edges` returns something other than a list of node ids. Before P1 that refusal carried the
# primitive's name, which the caller never called; it now reads `gen-graph.cycles: … (in lowlink)`,
# the door first and the primitive as the suffix. The unplanted arm is a two-node cycle and asserts
# the nodes on its cycle as a STDOUT VALUE; the arms differ by the accessor's `edges` alone.
row111='let
  genGraph = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.graph;
  looped = { nodes = [ "warp" "weft" ]; edges = id: { warp = [ "weft" ]; weft = [ "warp" ]; }.${id}; };
  planted = { nodes = [ "a" ]; edges = _: 5; };
  green = builtins.toJSON (genGraph.cycles looped);
  red = builtins.toJSON (genGraph.cycles planted);
  caught = if (builtins.tryEval (builtins.deepSeq (genGraph.cycles planted) true)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row111 unplanted (a well-typed accessor answers its cycle)" \
  "${row111/BODY/green}" 0 "" "$tmpdir/row111-green.err" '["warp","weft"]'
check "T5 row111 planted   (a primitive refusal reached through cycles names the door, den-hoag-7gp66 P1 R6)" \
  "${row111/BODY/red}" 1 \
  'gen-graph.cycles: edges "a" returned a int, not a list of node ids (in lowlink)' \
  "$tmpdir/row111-red.err"
check "T5 row111 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row111/BODY/caught}" 0 "" "$tmpdir/row111-catch.err" 'CAUGHT'
