# shellcheck shell=bash
# ── row 129 -- a redeclaration whose merge drops a wrapper's check, BY NAME (C117, den-hoag-lsmnv) ──
# `addCheck` over gen-merge's `int` keeps `int`'s name and relation, so declaring it beside plain `int`
# joins to bare `int`, which would serve what the added check refuses. gen-merge meets the pair
# (den-hoag-l1j4q, owner-ruled 2026-10-06): the planted arm defines `5`, which the added check
# rejects, and is refused by name. The unplanted arm declares the same pair and serves `2`, so a fold
# refusing every redeclaration cannot pass.
row_redeclaration_whose_merge_drops_a_wrappers_check='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
  short = lib.types.addCheck genMerge.types.int (n: n < 3);
in toString (genMerge.evalModuleTree { } [
    { options.spool = genMerge.mkOption { type = EARLIER; }; }
    { options.spool = genMerge.mkOption { type = short; }; }
    { spool = VALUE; }
  ]).config.spool'
row_redeclaration_whose_merge_drops_a_wrappers_checkpair="${row_redeclaration_whose_merge_drops_a_wrappers_check/EARLIER/genMerge.types.int}"
row_redeclaration_whose_merge_drops_a_wrappers_checkunplanted="${row_redeclaration_whose_merge_drops_a_wrappers_checkpair/VALUE/2}"
row_redeclaration_whose_merge_drops_a_wrappers_checkplanted="${row_redeclaration_whose_merge_drops_a_wrappers_checkpair/VALUE/5}"
check "T5 redeclaration-whose-merge-drops-a-wrappers-check unplanted (a wrapped int beside plain int, a value the wrapper accepts)" "$row_redeclaration_whose_merge_drops_a_wrappers_checkunplanted" 0 "" \
  "$tmpdir/redeclaration-whose-merge-drops-a-wrappers-check-green.err" '2'
check "T5 redeclaration-whose-merge-drops-a-wrappers-check planted   (a wrapped int beside plain int, a value the wrapper rejects)" "$row_redeclaration_whose_merge_drops_a_wrappers_checkplanted" 1 \
  "a definition for option \`spool' is not of type \`signed integer'" \
  "$tmpdir/redeclaration-whose-merge-drops-a-wrappers-check-red.err"
