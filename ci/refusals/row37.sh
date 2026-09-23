# shellcheck shell=bash
# ── row 37 -- a nested tree used as a container element refuses the key it cannot report
#    (mirrors C44's `element-tree-refuses-per-level`, gen-merge 0s6zi) ──
# A `check = false` tree typed as an `attrsOf` element has no undeclared report, and a key its own
# level does not declare used to vanish at exit 0 with `.config` smaller. It is now refused by name,
# naming the key, its file and the element. The arms differ by ONE key in the element; the unplanted
# arm asserts the value, so a library refusing every element cannot pass it.
row37='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
  pocketTree = (genMerge.evalModuleTree {
    check = false;
    modules = [ { options.selvedge = genMerge.mkOption { type = genMerge.types.str; }; } ];
  }).type;
in builtins.toJSON (genMerge.evalModuleTree {
  check = false;
  modules = [
    { options.pockets = genMerge.mkOption { type = genMerge.types.attrsOf pocketTree; }; }
    { _file = "row37"; config.pockets.welt = { selvedge = "pinked"; } // PLANT; }
  ];
}).config.pockets'
check "T5 row37 unplanted (a clean element of a lax nested tree)" \
  "${row37/PLANT/{ \}}" 0 "" \
  "$tmpdir/row37-green.err" '{"welt":{"selvedge":"pinked"}}'
check "T5 row37 planted   (the same element with one key its tree does not declare)" \
  "${row37/PLANT/{ fray = \"loose\"; \}}" 1 \
  "is not declared by the nested tree that owns it (defined in row37); the tree at \`pockets.welt' is merged where no undeclared report is carried" \
  "$tmpdir/row37-red.err"
