# shellcheck shell=bash
# ── row 101 -- gen-schema's retired `ref` is refused BY NAME, catchably, and names `declarationOf`
#    (den-hoag-2zjg1; C87) ──
# The type of a field holding a declaration is `declarationOf`; the old name stays published as a
# tombstone so a caller meets a refusal that names the new constructor instead of a missing
# attribute. The unplanted arm builds the same field through `declarationOf` and asserts a STDOUT
# VALUE, its type name, so a schema that refused everything cannot pass it. Every addressing is
# bound in the prelude: a `}` inside a `${row101/BODY/...}` replacement would end the expansion early.
row_gen_schemas_retired_ref='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  green = (schema.declarationOf "aglet").name;
  planted = schema.ref "aglet";
  red = builtins.seq planted "admitted";
  caught = if (builtins.tryEval (builtins.seq planted true)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 gen-schemas-retired-ref unplanted (the field typed through declarationOf answers)" \
  "${row_gen_schemas_retired_ref/BODY/green}" 0 "" "$tmpdir/gen-schemas-retired-ref-green.err" 'declarationOf(aglet)'
check "T5 gen-schemas-retired-ref planted   (the retired ref is refused by name)" \
  "${row_gen_schemas_retired_ref/BODY/red}" 1 \
  'gen-schema: `ref` is renamed `declarationOf`.' "$tmpdir/gen-schemas-retired-ref-red.err"
check "T5 gen-schemas-retired-ref catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_gen_schemas_retired_ref/BODY/caught}" 0 "" "$tmpdir/gen-schemas-retired-ref-catch.err" 'CAUGHT'
