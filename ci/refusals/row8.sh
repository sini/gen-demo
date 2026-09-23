# shellcheck shell=bash
# ── row 8 -- a bare kind-name string passed where a kind VALUE belongs (mirrors gen-select's
# second door, `sel.kind`, exercised elsewhere in this corpus only through gen-scope's own
# kind values) ──
row8='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSelect = gen.lib.substrate.select;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  tree = genMerge.evalModuleTree {
    modules = [
      { options.schema = genSchema.mkSchemaOption {}; }
      { config.schema.thimble = { options.spool = genMerge.mkOption { type = genMerge.types.str; default = "linen"; }; }; }
    ];
  };
  kindValue = tree.config.schema.thimble;
in builtins.toJSON (builtins.attrNames (genSelect.kind ARG))'
check "T5 row8 unplanted (a real kind value, minted through the schema)" "${row8/ARG/kindValue}" 0 "" \
  "$tmpdir/row8-green.err" '["__sel","kind"]'
check "T5 row8 planted   (a bare kind-name string, never a kind value)" "${row8/ARG/\"thimble\"}" 1 \
  "gen-select: sel.kind expects a kind value" \
  "$tmpdir/row8-red.err"
