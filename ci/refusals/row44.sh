# shellcheck shell=bash
# ── row 44 -- a redeclared option's type is decided by the LATER declaration, as nixpkgs decides it
#    (gen-merge e07bf) ──
# `sealed` is `loom` whose own relation refuses every partner; declared SECOND it decides and
# refuses, declared FIRST it is the partner `loom` decides against, and it merges. Before e07bf both
# halves were inverted. The planted stderr is row 30's template, so this row stays out of the
# cross-row control, as row34 does.
row44='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  lib = (builtins.getFlake (toString ./.)).inputs.nixpkgs.lib;
  genMerge = gen.lib.modules.merge;
  loom = lib.types.attrsOf lib.types.str;
  sealed = loom // { typeMerge = _: null; };
in builtins.concatStringsSep "," (builtins.attrValues (genMerge.evalModuleTree {
  modules = [
    { options.shed = genMerge.mkOption { type = FIRST; }; }
    { options.shed = genMerge.mkOption { type = SECOND; }; }
    { config.shed.warp = "sateen"; }
  ];
}).config.shed)'
row44a="${row44/FIRST/sealed}"; row44unplanted="${row44a/SECOND/loom}"
row44b="${row44/FIRST/loom}"; row44planted="${row44b/SECOND/sealed}"
check "T5 row44 unplanted (the refusing relation declared first; the later type decides and merges)" \
  "$row44unplanted" 0 "" "$tmpdir/row44-green.err" 'sateen'
check "T5 row44 planted   (the refusing relation declared second decides, refused by name)" \
  "$row44planted" 1 "declared with types that do not merge" "$tmpdir/row44-red.err"
