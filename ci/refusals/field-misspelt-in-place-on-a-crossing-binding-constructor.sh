# shellcheck shell=bash
# ── row 115 -- a field misspelt IN PLACE on a crossing binding constructor is refused by name,
#    catchably (den-hoag-ekum1; ADR-0025 item 1) ──
# gen-bind's `crossing.binding.plain` takes one open data record, `{ value; mark; }`, every field
# required (R5). Its native closed formal used to abort on `{ vaule; mark; }` (`called without
# required argument 'value'`), past `tryEval`. It is a `prelude.door` now: the misspelling leaves
# `value` missing, which is refused when the constructor is applied, naming the constructor, the
# field and the required set. The unplanted arm is the same constructor under the correct spelling
# and asserts the binding it builds, so a door that refused everything cannot pass it. Every arm is
# bound in the prelude, as row 113's are.
row_field_misspelt_in_place_on_a_crossing_binding_constructor='let
  x = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.bind.crossing;
  answered = (x.binding.plain { value = "linen"; mark = x.mark.open; }).__binding;
  misspelt = builtins.toJSON (x.binding.plain { vaule = "linen"; mark = x.mark.open; });
  caught = if (builtins.tryEval (builtins.seq (x.binding.plain { vaule = "linen"; mark = x.mark.open; }) null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 field-misspelt-in-place-on-a-crossing-binding-constructor unplanted (binding.plain with its fields spelt right builds the binding)" \
  "${row_field_misspelt_in_place_on_a_crossing_binding_constructor/BODY/answered}" 0 "" "$tmpdir/field-misspelt-in-place-on-a-crossing-binding-constructor-green.err" 'Plain'
check "T5 field-misspelt-in-place-on-a-crossing-binding-constructor planted   (a field misspelt in place on binding.plain is refused by name)" \
  "${row_field_misspelt_in_place_on_a_crossing_binding_constructor/BODY/misspelt}" 1 \
  "gen-bind.crossing.binding.plain: required field 'value' is missing (required: 'value', 'mark') (in prelude.checkRequired)" \
  "$tmpdir/field-misspelt-in-place-on-a-crossing-binding-constructor-red.err"
check "T5 field-misspelt-in-place-on-a-crossing-binding-constructor catchable  (the misspelling is caught by tryEval at the constructor's application, not an abort)" \
  "${row_field_misspelt_in_place_on_a_crossing_binding_constructor/BODY/caught}" 0 "" "$tmpdir/field-misspelt-in-place-on-a-crossing-binding-constructor-catch.err" 'CAUGHT'
