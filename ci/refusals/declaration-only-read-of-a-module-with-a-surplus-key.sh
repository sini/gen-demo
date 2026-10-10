# shellcheck shell=bash
# ── row 35 -- a declaration-only read of a module with a surplus key (mirrors C40's
#    `declaration-read-syntax`, gen-merge 4kw63) ──
# The refusals used to sit in the config reader, so a read of declarations alone answered without
# the typo'd key. The arms differ by the one key's spelling; the unplanted arm prints the names, the
# engine's `_module` records first, as nixpkgs' `evalModules` names them (den-hoag-a67l3).
row_declaration_only_read_of_a_module_with_a_surplus_key='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
  o = genMerge.mkOption { type = genMerge.types.str; default = "none"; };
in builtins.concatStringsSep "," (builtins.attrNames (genMerge.declaredOptions { } [ { _file = "/demo/typo.nix"; options.spool = o; KEY.weft = o; } ]))'
check "T5 declaration-only-read-of-a-module-with-a-surplus-key unplanted (both options spelled right)" "${row_declaration_only_read_of_a_module_with_a_surplus_key/KEY/options}" 0 "" \
  "$tmpdir/declaration-only-read-of-a-module-with-a-surplus-key-green.err" '_module,spool,weft'
check "T5 declaration-only-read-of-a-module-with-a-surplus-key planted   (a declaration-only read of a typo key)" "${row_declaration_only_read_of_a_module_with_a_surplus_key/KEY/option}" 1 \
  "gen-merge: module \`/demo/typo.nix' has an unsupported attribute \`option'" \
  "$tmpdir/declaration-only-read-of-a-module-with-a-surplus-key-red.err"
