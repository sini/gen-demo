# shellcheck shell=bash
# ── row 36 -- a foreign type's `check` before gen-merge's fold (mirrors C41's `foreign-type-check`,
#    gen-merge v4h7k) ──
# nixpkgs checks every definition against the option type's `check` before its merge; gen-merge's own
# folds used to skip a foreign type's `check`, so `lib.types.str` accepted `1`. The arms differ by the
# one value; the unplanted arm prints it, so a fold refusing every definition cannot pass.
row36='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
in toString (genMerge.evalModuleTree {
  modules = [
    { options.spool = genMerge.mkOption { type = lib.types.str; }; }
    { _file = "/demo/spool.nix"; spool = VALUE; }
  ];
}).config.spool'
check "T5 row36 unplanted (a string for a foreign str)" "${row36/VALUE/\"sateen\"}" 0 "" \
  "$tmpdir/row36-green.err" 'sateen'
check "T5 row36 planted   (an int for a foreign str)" "${row36/VALUE/1}" 1 \
  "gen-merge: a definition for option \`spool' is not of type \`string', in \`/demo/spool.nix'" \
  "$tmpdir/row36-red.err"
