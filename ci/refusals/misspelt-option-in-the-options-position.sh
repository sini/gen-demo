# shellcheck shell=bash
# ── row 113 -- a misspelt option IN THE OPTIONS POSITION is refused by name, catchably, when the
#    options are applied (den-hoag-7gp66 P2 cell G1; den-hoag-nvrl1; ADR-0025 item 1) ──
# gen-graph's `ancestorsOf` takes its options first, in one closed set (`maxDepth`, retired). The
# typo `maxdepth` used to ride on the accessor record, where an open record admitted it and the
# walk answered uncapped. It is refused now when `ancestorsOf opts` is formed, before any record or
# start id, naming the door, the field and the accepted set. The unplanted arm is the same door
# under `{ }`, over the same record and start, and asserts the answer, so a door that refused
# everything cannot pass it. Every arm is bound in the prelude: a `}` inside a `${row113/BODY/...}`
# replacement would end the expansion early.
row_misspelt_option_in_the_options_position='let
  genGraph = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.graph;
  parents = { parent = id: { spool = "twill"; twill = "awl"; }.${id} or null; };
  answered = builtins.toJSON (genGraph.ancestorsOf { } parents "spool");
  misspelt = builtins.toJSON (genGraph.ancestorsOf { maxdepth = 1; } parents "spool");
  caught = if (builtins.tryEval (builtins.seq (genGraph.ancestorsOf { maxdepth = 1; }) null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 misspelt-option-in-the-options-position unplanted (ancestorsOf under { } answers over the accessor record)" \
  "${row_misspelt_option_in_the_options_position/BODY/answered}" 0 "" "$tmpdir/misspelt-option-in-the-options-position-green.err" '["twill","awl"]'
check "T5 misspelt-option-in-the-options-position planted   (a misspelt option in the options position is refused by name)" \
  "${row_misspelt_option_in_the_options_position/BODY/misspelt}" 1 \
  "gen-graph.ancestorsOf: 'maxdepth' is not an option of this door; the options are closed (accepted: 'maxDepth') (in prelude.checkOptions)" \
  "$tmpdir/misspelt-option-in-the-options-position-red.err"
check "T5 misspelt-option-in-the-options-position catchable  (the refusal is caught by tryEval at the options application, not an abort)" \
  "${row_misspelt_option_in_the_options_position/BODY/caught}" 0 "" "$tmpdir/misspelt-option-in-the-options-position-catch.err" 'CAUGHT'
