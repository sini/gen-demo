# shellcheck shell=bash
# ── rows 79/80 -- an ad-hoc `check` override of a nixpkgs v2 type (mirrors C61's
#    `foreign-v2-check-override`, den-hoag-v2-check-override-accepted-ku5dt) ──
# Row 79: nixpkgs refuses a v2 type whose `check` is replaced by `//` (its merge computes the verdict
# from the check it shipped), and gen-merge used to accept it. Row 80: on a submodule-bearing v2 type
# nixpkgs erases the override without a word when it rebuilds the type; gen-merge refuses it by name.
# Each unplanted arm is the same option with the plant removed and prints the value.
row_ad_hoc_check_override_of_a_nixpkgs_v2_type='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
in (genMerge.evalModuleTree { } [
    { options.spool = genMerge.mkOption { type = TYPE; }; }
    { spool.warp = "sateen"; }
  ]).config.spool.warp'
row_ad_hoc_check_override_of_a_nixpkgs_v2_typestated='lib.types.addCheck (lib.types.attrsOf lib.types.str) builtins.isAttrs'
row_ad_hoc_check_override_of_a_nixpkgs_v2_typeplant='lib.types.attrsOf lib.types.str // { check = builtins.isAttrs; }'
row_ad_hoc_check_override_of_a_nixpkgs_v2_typeunplanted="${row_ad_hoc_check_override_of_a_nixpkgs_v2_type/TYPE/$row_ad_hoc_check_override_of_a_nixpkgs_v2_typestated}"
row_ad_hoc_check_override_of_a_nixpkgs_v2_typeplanted="${row_ad_hoc_check_override_of_a_nixpkgs_v2_type/TYPE/$row_ad_hoc_check_override_of_a_nixpkgs_v2_typeplant}"
check "T5 ad-hoc-check-override-of-a-nixpkgs-v2-type unplanted (the check stated with addCheck)" "$row_ad_hoc_check_override_of_a_nixpkgs_v2_typeunplanted" 0 "" \
  "$tmpdir/ad-hoc-check-override-of-a-nixpkgs-v2-type-green.err" 'sateen'
check "T5 ad-hoc-check-override-of-a-nixpkgs-v2-type planted   (an ad-hoc check override of a v2 type)" "$row_ad_hoc_check_override_of_a_nixpkgs_v2_typeplanted" 1 \
  "gen-merge: the option \`spool' has a type \`attribute set of string' that uses an ad-hoc" \
  "$tmpdir/ad-hoc-check-override-of-a-nixpkgs-v2-type-red.err"
row_stock_submodulebolt='lib.types.submodule { options.warp = lib.mkOption { type = lib.types.str; }; }'
row_stock_submoduleunplanted="${row_ad_hoc_check_override_of_a_nixpkgs_v2_type/TYPE/$row_stock_submodulebolt}"
row_stock_submoduleplant="$row_stock_submodulebolt // { check = builtins.isAttrs; }"
row_stock_submoduleplanted="${row_ad_hoc_check_override_of_a_nixpkgs_v2_type/TYPE/$row_stock_submoduleplant}"
check "T5 stock-submodule unplanted (the stock submodule)" "$row_stock_submoduleunplanted" 0 "" \
  "$tmpdir/stock-submodule-green.err" 'sateen'
check "T5 stock-submodule planted   (an ad-hoc check override of a submodule-bearing v2 type)" "$row_stock_submoduleplanted" 1 \
  "which the foreign engine erases without a word when it rebuilds a submodule-bearing type" \
  "$tmpdir/stock-submodule-red.err"
