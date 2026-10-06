# shellcheck shell=bash
# ── row 36 -- a foreign type's `check` before gen-merge's fold (mirrors C41's `foreign-type-check`,
#    gen-merge v4h7k) ──
# nixpkgs checks every definition against the option type's `check` before its merge; gen-merge's own
# folds used to skip a foreign type's `check`, so `lib.types.str` accepted `1`. The arms differ by the
# one value; the unplanted arm prints it, so a fold refusing every definition cannot pass.
row_foreign_types_check_before_gen_merges_fold='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
in toString (genMerge.evalModuleTree { } [
    { options.spool = genMerge.mkOption { type = lib.types.str; }; }
    { _file = "/demo/spool.nix"; spool = VALUE; }
  ]).config.spool'
check "T5 foreign-types-check-before-gen-merges-fold unplanted (a string for a foreign str)" "${row_foreign_types_check_before_gen_merges_fold/VALUE/\"sateen\"}" 0 "" \
  "$tmpdir/foreign-types-check-before-gen-merges-fold-green.err" 'sateen'
check "T5 foreign-types-check-before-gen-merges-fold planted   (an int for a foreign str)" "${row_foreign_types_check_before_gen_merges_fold/VALUE/1}" 1 \
  "gen-merge: a definition for option \`spool' is not of type \`string', in \`/demo/spool.nix'" \
  "$tmpdir/foreign-types-check-before-gen-merges-fold-red.err"
