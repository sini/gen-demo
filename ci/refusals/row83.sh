# shellcheck shell=bash
# ── row 83 -- a computed field named for a key gen-schema writes onto the kind value, refused by
#    name (den-hoag-ciu4r; ADR-0025) ──
# The computed fields are applied over the kind record `mkSchemaEntryType` writes, so a computed
# `options` replaced the published option plane: `selvage.options` read back as the computed value,
# at exit 0. The door reads the whole written key set; the message names the field and the set. The
# unplanted arm gives the computed field a free name and reads the plane, so a door refusing every
# computed field cannot pass.
row83='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  selvage = (merge.evalModuleTree { modules = [
    { options.schema = schema.mkSchemaOption { computed = _: _: { NAME = "sateen"; }; }; }
    { config.schema.selvage.options.ends = merge.mkOption { type = merge.types.int; default = 2; }; }
  ]; }).config.schema.selvage;
in BODY'
row83free="${row83/NAME/weft}"
row83opts="${row83/NAME/options}"
check "T5 row83 unplanted (a computed field with a free name lands beside the plane)" \
  "${row83free/BODY/builtins.toJSON [ selvage.weft (builtins.attrNames selvage.options) ]}" 0 "" \
  "$tmpdir/row83-green.err" '["sateen",["ends"]]'
check "T5 row83 planted   (a computed field named options, refused by name)" \
  "${row83opts/BODY/builtins.toJSON (builtins.attrNames selvage.options)}" 1 \
  "gen-schema: computed field 'options' is reserved — it is part of the kind-value contract; reserved computed-field names: __functor, kind, mixins, strict, keySemantics, options, refs, refinements, __mint, __sealed" \
  "$tmpdir/row83-red.err"
check "T5 row83 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row83opts/BODY/if (builtins.tryEval (builtins.deepSeq selvage.options true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row83-catch.err" 'CAUGHT'
