# shellcheck shell=bash
# ── row 83 -- a computed field named for a key gen-schema writes onto the kind value, refused by
#    name (den-hoag-ciu4r; ADR-0025) ──
# The computed fields are applied over the kind record `mkSchemaEntryType` writes, so a computed
# `options` replaced the published option plane: `selvage.options` read back as the computed value,
# at exit 0. The door reads the whole written key set; the message names the field and the set. The
# unplanted arm gives the computed field a free name and reads the plane, so a door refusing every
# computed field cannot pass.
row_computed_field_named_for_a_key_gen_schema_writes_onto_the_kind_value='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  selvage = (merge.evalModuleTree { } [
    { options.schema = schema.mkSchemaOption { computed = _: _: { NAME = "sateen"; }; }; }
    { config.schema.selvage.options.ends = merge.mkOption { type = merge.types.int; default = 2; }; }
  ]).config.schema.selvage;
in BODY'
row_computed_field_named_for_a_key_gen_schema_writes_onto_the_kind_valuefree="${row_computed_field_named_for_a_key_gen_schema_writes_onto_the_kind_value/NAME/weft}"
row_computed_field_named_for_a_key_gen_schema_writes_onto_the_kind_valueopts="${row_computed_field_named_for_a_key_gen_schema_writes_onto_the_kind_value/NAME/options}"
check "T5 computed-field-named-for-a-key-gen-schema-writes-onto-the-kind-value unplanted (a computed field with a free name lands beside the plane)" \
  "${row_computed_field_named_for_a_key_gen_schema_writes_onto_the_kind_valuefree/BODY/builtins.toJSON [ selvage.weft (builtins.attrNames selvage.options) ]}" 0 "" \
  "$tmpdir/computed-field-named-for-a-key-gen-schema-writes-onto-the-kind-value-green.err" '["sateen",["ends"]]'
check "T5 computed-field-named-for-a-key-gen-schema-writes-onto-the-kind-value planted   (a computed field named options, refused by name)" \
  "${row_computed_field_named_for_a_key_gen_schema_writes_onto_the_kind_valueopts/BODY/builtins.toJSON (builtins.attrNames selvage.options)}" 1 \
  "gen-schema: computed field 'options' is reserved — it is part of the kind-value contract; reserved computed-field names: __functor, kind, mixins, strict, keySemantics, options, refs, refinements, __mint, __sealed" \
  "$tmpdir/computed-field-named-for-a-key-gen-schema-writes-onto-the-kind-value-red.err"
check "T5 computed-field-named-for-a-key-gen-schema-writes-onto-the-kind-value catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_computed_field_named_for_a_key_gen_schema_writes_onto_the_kind_valueopts/BODY/if (builtins.tryEval (builtins.deepSeq selvage.options true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/computed-field-named-for-a-key-gen-schema-writes-onto-the-kind-value-catch.err" 'CAUGHT'
