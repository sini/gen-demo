# shellcheck shell=bash
# ── row 129 -- a redeclaration whose merge drops a wrapper's check, BY NAME (C117, den-hoag-lsmnv) ──
# `addCheck` over gen-merge's `int` keeps `int`'s name and relation, so declaring it beside plain `int`
# merges to bare `int` and would serve what the added check refuses. gen-merge refuses the pair and
# names whose check the merge dropped. The unplanted arm declares the one wrapped value twice and
# serves `2`, so a fold refusing every redeclaration cannot pass.
row129='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
  short = lib.types.addCheck genMerge.types.int (n: n < 3);
in toString (genMerge.evalModuleTree { } [
    { options.spool = genMerge.mkOption { type = EARLIER; }; }
    { options.spool = genMerge.mkOption { type = short; }; }
    { spool = 2; }
  ]).config.spool'
row129unplanted="${row129/EARLIER/short}"
row129planted="${row129/EARLIER/genMerge.types.int}"
check "T5 row129 unplanted (one wrapped value declared twice)" "$row129unplanted" 0 "" \
  "$tmpdir/row129-green.err" '2'
check "T5 row129 planted   (a wrapped int declared beside plain int)" "$row129planted" 1 \
  "a type that drops the \`check' a wrapper added to the first" \
  "$tmpdir/row129-red.err"
