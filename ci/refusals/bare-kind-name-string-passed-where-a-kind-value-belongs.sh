# shellcheck shell=bash
# ── row 8 -- a bare kind-name string passed where a kind VALUE belongs (mirrors gen-select's
# second door, `sel.kind`, exercised elsewhere in this corpus only through gen-scope's own
# kind values) ──
row_bare_kind_name_string_passed_where_a_kind_value_belongs='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSelect = gen.lib.substrate.select;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  tree = genMerge.evalModuleTree { } [
      { options.schema = genSchema.mkSchemaOption {}; }
      { config.schema.thimble = { options.spool = genMerge.mkOption { type = genMerge.types.str; default = "linen"; }; }; }
    ];
  kindValue = tree.config.schema.thimble;
in builtins.toJSON (builtins.attrNames (genSelect.kind ARG))'
check "T5 bare-kind-name-string-passed-where-a-kind-value-belongs unplanted (a real kind value, minted through the schema)" "${row_bare_kind_name_string_passed_where_a_kind_value_belongs/ARG/kindValue}" 0 "" \
  "$tmpdir/bare-kind-name-string-passed-where-a-kind-value-belongs-green.err" '["__sel","identity","name","sealed"]'
check "T5 bare-kind-name-string-passed-where-a-kind-value-belongs planted   (a bare kind-name string, never a kind value)" "${row_bare_kind_name_string_passed_where_a_kind_value_belongs/ARG/\"thimble\"}" 1 \
  "gen-select: sel.kind expects a kind value" \
  "$tmpdir/bare-kind-name-string-passed-where-a-kind-value-belongs-red.err"
