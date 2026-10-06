# shellcheck shell=bash
# ── row 129 -- a redeclaration whose merge drops a wrapper's check, BY NAME (C117, den-hoag-lsmnv) ──
# `addCheck` over gen-merge's `int` keeps `int`'s name and relation, so declaring it beside plain `int`
# merges to bare `int` and would serve what the added check refuses. gen-merge refuses the pair and
# names whose check the merge dropped. The unplanted arm declares the one wrapped value twice and
# serves `2`, so a fold refusing every redeclaration cannot pass.
row_redeclaration_whose_merge_drops_a_wrappers_check='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
  short = lib.types.addCheck genMerge.types.int (n: n < 3);
in toString (genMerge.evalModuleTree { } [
    { options.spool = genMerge.mkOption { type = EARLIER; }; }
    { options.spool = genMerge.mkOption { type = short; }; }
    { spool = 2; }
  ]).config.spool'
row_redeclaration_whose_merge_drops_a_wrappers_checkunplanted="${row_redeclaration_whose_merge_drops_a_wrappers_check/EARLIER/short}"
row_redeclaration_whose_merge_drops_a_wrappers_checkplanted="${row_redeclaration_whose_merge_drops_a_wrappers_check/EARLIER/genMerge.types.int}"
check "T5 redeclaration-whose-merge-drops-a-wrappers-check unplanted (one wrapped value declared twice)" "$row_redeclaration_whose_merge_drops_a_wrappers_checkunplanted" 0 "" \
  "$tmpdir/redeclaration-whose-merge-drops-a-wrappers-check-green.err" '2'
check "T5 redeclaration-whose-merge-drops-a-wrappers-check planted   (a wrapped int declared beside plain int)" "$row_redeclaration_whose_merge_drops_a_wrappers_checkplanted" 1 \
  "a type that drops the \`check' a wrapper added to the first" \
  "$tmpdir/redeclaration-whose-merge-drops-a-wrappers-check-red.err"
