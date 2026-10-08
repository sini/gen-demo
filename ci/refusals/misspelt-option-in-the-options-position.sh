# shellcheck shell=bash
# ── row 113 -- a misspelt option IN THE OPTIONS POSITION is refused by name, catchably, when the
#    options are applied (den-hoag-7gp66 P2 cell G1; den-hoag-nvrl1; ADR-0025 item 1) ──
# gen-graph's `pathsBetween` takes its options first, in one closed set (`maxDepth`). A typo
# `maxdepth` on the accessor record would ride an open record and the walk would answer uncapped.
# In the options position it is refused when `pathsBetween opts` is formed, before any record or
# end ids, naming the door, the field and the accepted set. The unplanted arm is the same door
# under `{ }`, over the same record and start, and asserts the answer, so a door that refused
# everything cannot pass it. Every arm is bound in the prelude: a `}` inside a `${row113/BODY/...}`
# replacement would end the expansion early.
row_misspelt_option_in_the_options_position='let
  genGraph = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.graph;
  acc = { edges = id: { awl = [ "twill" ]; twill = [ "spool" ]; }.${id} or [ ]; };
  answered = builtins.toJSON (genGraph.pathsBetween { } acc "awl" "spool");
  misspelt = builtins.toJSON (genGraph.pathsBetween { maxdepth = 1; } acc "awl" "spool");
  caught = if (builtins.tryEval (builtins.seq (genGraph.pathsBetween { maxdepth = 1; }) null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 misspelt-option-in-the-options-position unplanted (pathsBetween under { } answers over the accessor record)" \
  "${row_misspelt_option_in_the_options_position/BODY/answered}" 0 "" "$tmpdir/misspelt-option-in-the-options-position-green.err" '[["awl","twill","spool"]]'
check "T5 misspelt-option-in-the-options-position planted   (a misspelt option in the options position is refused by name)" \
  "${row_misspelt_option_in_the_options_position/BODY/misspelt}" 1 \
  "gen-graph.pathsBetween: 'maxdepth' is not an option of this door; the options are closed (accepted: 'maxDepth') (in prelude.checkOptions)" \
  "$tmpdir/misspelt-option-in-the-options-position-red.err"
check "T5 misspelt-option-in-the-options-position catchable  (the refusal is caught by tryEval at the options application, not an abort)" \
  "${row_misspelt_option_in_the_options_position/BODY/caught}" 0 "" "$tmpdir/misspelt-option-in-the-options-position-catch.err" 'CAUGHT'
