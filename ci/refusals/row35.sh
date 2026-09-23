# shellcheck shell=bash
# ── row 35 -- a declaration-only read of a module with a surplus key (mirrors C40's
#    `declaration-read-syntax`, gen-merge 4kw63) ──
# The refusals used to sit in the config reader, so a read of declarations alone answered without
# the typo'd key. The arms differ by the one key's spelling; the unplanted arm prints the names.
row35='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
  o = genMerge.mkOption { type = genMerge.types.str; default = "none"; };
in builtins.concatStringsSep "," (builtins.attrNames (genMerge.declaredOptions {
  modules = [ { _file = "/demo/typo.nix"; options.spool = o; KEY.weft = o; } ];
}))'
check "T5 row35 unplanted (both options spelled right)" "${row35/KEY/options}" 0 "" \
  "$tmpdir/row35-green.err" 'spool,weft'
check "T5 row35 planted   (a declaration-only read of a typo key)" "${row35/KEY/option}" 1 \
  "gen-merge: module \`/demo/typo.nix' has an unsupported attribute \`option'" \
  "$tmpdir/row35-red.err"
