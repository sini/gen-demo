# shellcheck shell=bash
# ── row 41 -- a structural container refuses a wrong-kind definition by name (gen-merge 5npwi) ──
# `listOf` walked a non-list definition with `imap0`, so the interpreter aborted UNCATCHABLY with
# `expected a list but found a string`, naming neither option nor file. The fold now checks its
# domain first, through the binding it states as `admits`. The arms differ by the one definition;
# the unplanted arm prints the value, so a fold refusing every definition cannot pass, and the
# catchable arm measures ADR-0025 item 1 (row 24's form).
row41='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
in BODY (genMerge.evalModuleTree {
  modules = [
    { options.bobbins = genMerge.mkOption { type = genMerge.types.listOf genMerge.types.str; }; }
    { _file = "/demo/bobbins.nix"; config.bobbins = DEF; }
  ];
}).config.bobbins'
row41unplanted="${row41/DEF/[ \"linen\" ]}"
row41planted="${row41/DEF/\"linen\"}"
check "T5 row41 unplanted (a list definition)" "${row41unplanted/BODY/builtins.toJSON}" 0 "" \
  "$tmpdir/row41-green.err" '["linen"]'
check "T5 row41 planted   (a string where a list is declared, refused by name)" \
  "${row41planted/BODY/builtins.toJSON}" 1 \
  "gen-merge: option \`bobbins' has definitions \`listOf' cannot consume (/demo/bobbins.nix)" \
  "$tmpdir/row41-red.err"
check "T5 row41 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row41planted/BODY/(v: if (builtins.tryEval (builtins.deepSeq v true)).success then \"ADMITTED\" else \"CAUGHT\")}" 0 "" \
  "$tmpdir/row41-catch.err" 'CAUGHT'
