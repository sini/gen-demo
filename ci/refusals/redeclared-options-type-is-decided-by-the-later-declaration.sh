# shellcheck shell=bash
# ── row 44 -- a redeclared option's type is decided by the LATER declaration, as nixpkgs decides it
#    (gen-merge e07bf) ──
# `sealed` is `loom` whose own relation refuses every partner; declared SECOND it decides and
# refuses, declared FIRST it is the partner `loom` decides against, and it merges. Before e07bf both
# halves were inverted. The planted stderr is row 30's template, so this row stays out of the
# cross-row control, as row34 does.
row_redeclared_options_type_is_decided_by_the_later_declaration='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  lib = (builtins.getFlake (toString ./.)).inputs.nixpkgs.lib;
  genMerge = gen.lib.modules.merge;
  loom = lib.types.attrsOf lib.types.str;
  sealed = loom // { typeMerge = _: null; };
in builtins.concatStringsSep "," (builtins.attrValues (genMerge.evalModuleTree { } [
    { options.shed = genMerge.mkOption { type = FIRST; }; }
    { options.shed = genMerge.mkOption { type = SECOND; }; }
    { config.shed.warp = "sateen"; }
  ]).config.shed)'
row_redeclared_options_type_is_decided_by_the_later_declarationa="${row_redeclared_options_type_is_decided_by_the_later_declaration/FIRST/sealed}"; row_redeclared_options_type_is_decided_by_the_later_declarationunplanted="${row_redeclared_options_type_is_decided_by_the_later_declarationa/SECOND/loom}"
row_redeclared_options_type_is_decided_by_the_later_declarationb="${row_redeclared_options_type_is_decided_by_the_later_declaration/FIRST/loom}"; row_redeclared_options_type_is_decided_by_the_later_declarationplanted="${row_redeclared_options_type_is_decided_by_the_later_declarationb/SECOND/sealed}"
check "T5 redeclared-options-type-is-decided-by-the-later-declaration unplanted (the refusing relation declared first; the later type decides and merges)" \
  "$row_redeclared_options_type_is_decided_by_the_later_declarationunplanted" 0 "" "$tmpdir/redeclared-options-type-is-decided-by-the-later-declaration-green.err" 'sateen'
check "T5 redeclared-options-type-is-decided-by-the-later-declaration planted   (the refusing relation declared second decides, refused by name)" \
  "$row_redeclared_options_type_is_decided_by_the_later_declarationplanted" 1 "declared with types that do not merge" "$tmpdir/redeclared-options-type-is-decided-by-the-later-declaration-red.err"
