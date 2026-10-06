# shellcheck shell=bash
# ── row 31 -- a surplus key beside an explicit `config` (mirrors C35's `module-reader-syntax`,
#    gen-merge s7826) ──
# gen-merge reads a module's keys the way nixpkgs' `unifyModuleSyntax` does: once a module names
# `config` (or `options`), every key outside the reserved set is surplus, and surplus is refused BY
# NAME with the module's `_file`, where the reader used to drop it unread. The two arms differ by the
# one surplus key; the unplanted arm prints the value, so a reader refusing every module cannot pass.
row_surplus_key_beside_an_explicit_config='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
in (genMerge.evalModuleTree { } [
    { options.spool = genMerge.mkOption { type = genMerge.types.str; default = "none"; }; }
    ({ _file = "/demo/typo.nix"; config.spool = "sateen"; } // { SURPLUS })
  ]).config.spool'
check "T5 surplus-key-beside-an-explicit-config unplanted (an explicit config and nothing beside it)" "${row_surplus_key_beside_an_explicit_config/SURPLUS/}" 0 "" \
  "$tmpdir/surplus-key-beside-an-explicit-config-green.err" 'sateen'
check "T5 surplus-key-beside-an-explicit-config planted   (a surplus key beside an explicit config)" "${row_surplus_key_beside_an_explicit_config/SURPLUS/spol = 1;}" 1 \
  "gen-merge: module \`/demo/typo.nix' has an unsupported attribute \`spol'" \
  "$tmpdir/surplus-key-beside-an-explicit-config-red.err"
