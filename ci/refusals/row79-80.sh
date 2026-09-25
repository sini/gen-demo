# shellcheck shell=bash
# ── rows 79/80 -- an ad-hoc `check` override of a nixpkgs v2 type (mirrors C61's
#    `foreign-v2-check-override`, den-hoag-v2-check-override-accepted-ku5dt) ──
# Row 79: nixpkgs refuses a v2 type whose `check` is replaced by `//` (its merge computes the verdict
# from the check it shipped), and gen-merge used to accept it. Row 80: on a submodule-bearing v2 type
# nixpkgs erases the override without a word when it rebuilds the type; gen-merge refuses it by name.
# Each unplanted arm is the same option with the plant removed and prints the value.
row79='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
in (genMerge.evalModuleTree {
  modules = [
    { options.spool = genMerge.mkOption { type = TYPE; }; }
    { spool.warp = "sateen"; }
  ];
}).config.spool.warp'
row79stated='lib.types.addCheck (lib.types.attrsOf lib.types.str) builtins.isAttrs'
row79plant='lib.types.attrsOf lib.types.str // { check = builtins.isAttrs; }'
row79unplanted="${row79/TYPE/$row79stated}"
row79planted="${row79/TYPE/$row79plant}"
check "T5 row79 unplanted (the check stated with addCheck)" "$row79unplanted" 0 "" \
  "$tmpdir/row79-green.err" 'sateen'
check "T5 row79 planted   (an ad-hoc check override of a v2 type)" "$row79planted" 1 \
  "gen-merge: the option \`spool' has a type \`attribute set of string' that uses an ad-hoc" \
  "$tmpdir/row79-red.err"
row80bolt='lib.types.submodule { options.warp = lib.mkOption { type = lib.types.str; }; }'
row80unplanted="${row79/TYPE/$row80bolt}"
row80plant="$row80bolt // { check = builtins.isAttrs; }"
row80planted="${row79/TYPE/$row80plant}"
check "T5 row80 unplanted (the stock submodule)" "$row80unplanted" 0 "" \
  "$tmpdir/row80-green.err" 'sateen'
check "T5 row80 planted   (an ad-hoc check override of a submodule-bearing v2 type)" "$row80planted" 1 \
  "which the foreign engine erases without a word when it rebuilds a submodule-bearing type" \
  "$tmpdir/row80-red.err"
