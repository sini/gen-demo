# shellcheck shell=bash
# ── row 149 -- a fixpoint step that withdraws an edge the accumulator holds is refused BY NAME, even
#    when it preserves the edge COUNT (gen-graph ba6d1df, den-hoag-acgy; ADR-0025 item 1) ──
# `fixpoint`'s termination guard tests the subset order over edge content, where it used to test the
# cardinality: a step that retracts `a → x` and asserts `a → y` leaves the count unchanged, so the
# oscillation passed the guard and its walk was returned as a fixpoint. The planted step does exactly
# that; the unplanted step only adds, and answers. The count-only guard still refuses a step that
# shrinks, so the planted arm is the one a cardinality test could not see.
row_fixpoint_step_that_withdraws_an_edge_the_accumulator_holds='let
  genGraph = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.graph;
  run = step: genGraph.fixpoint { } step { a = [ "x" ]; };
in BODY'
row_fixpoint_step_that_withdraws_an_edge_the_accumulator_holdsok='_: { a = [ "x" "y" ]; }'
row_fixpoint_step_that_withdraws_an_edge_the_accumulator_holdsswap='_: { a = [ "y" ]; }'
check "T5 fixpoint-step-that-withdraws-an-edge-the-accumulator-holds unplanted (an ascending step reaches its fixpoint)" \
  "${row_fixpoint_step_that_withdraws_an_edge_the_accumulator_holds/BODY/builtins.toJSON (run ($row_fixpoint_step_that_withdraws_an_edge_the_accumulator_holdsok))}" 0 "" \
  "$tmpdir/fixpoint-step-that-withdraws-an-edge-the-accumulator-holds-green.err" '{"a":["x","y"]}'
check "T5 fixpoint-step-that-withdraws-an-edge-the-accumulator-holds planted   (a size-preserving step that withdraws an edge is refused by name)" \
  "${row_fixpoint_step_that_withdraws_an_edge_the_accumulator_holds/BODY/builtins.toJSON (run ($row_fixpoint_step_that_withdraws_an_edge_the_accumulator_holdsswap))}" 1 \
  "gen-graph: fixpoint step is not ascending: it withdrew 1 edge(s) the accumulator already held: a → x" \
  "$tmpdir/fixpoint-step-that-withdraws-an-edge-the-accumulator-holds-red.err"
check "T5 fixpoint-step-that-withdraws-an-edge-the-accumulator-holds catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_fixpoint_step_that_withdraws_an_edge_the_accumulator_holds/BODY/if (builtins.tryEval (builtins.deepSeq (run ($row_fixpoint_step_that_withdraws_an_edge_the_accumulator_holdsswap)) true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/fixpoint-step-that-withdraws-an-edge-the-accumulator-holds-catch.err" 'CAUGHT'
