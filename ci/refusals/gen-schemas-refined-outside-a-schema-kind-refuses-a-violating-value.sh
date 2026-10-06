# shellcheck shell=bash
# ── row 136 -- gen-schema's `refined` outside a schema kind refuses a violating value, BY NAME
#    (den-hoag-refined-outside-kind-silent-1jlsq; ADR-0025 item 1) ──
# A refined type's refinements are part of its membership wherever it is used. In a plain option,
# outside any kind, `refined int positive` used to admit `-1`, because only a kind's pipeline read the
# refinement. It now refuses in gen-merge's words, naming the option and the refinement's message. The
# unplanted arm defines `4` on the same option and asserts a STDOUT VALUE, so a type that refused every
# value cannot pass it; the two arms differ by the defined value alone.
row_gen_schemas_refined_outside_a_schema_kind_refuses_a_violating_value='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  read = v: toString (merge.evalModuleTree { } [
      { options.spool = merge.mkOption { type = schema.refined merge.types.int schema.refinements.positive; }; }
      { spool = v; }
    ]).config.spool;
  green = read 4;
  red = read (-1);
  caught = if (builtins.tryEval red).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 gen-schemas-refined-outside-a-schema-kind-refuses-a-violating-value unplanted (a member of the refined type is admitted)" \
  "${row_gen_schemas_refined_outside_a_schema_kind_refuses_a_violating_value/BODY/green}" 0 "" "$tmpdir/gen-schemas-refined-outside-a-schema-kind-refuses-a-violating-value-green.err" '4'
check "T5 gen-schemas-refined-outside-a-schema-kind-refuses-a-violating-value planted   (a value failing the refinement is refused by name)" \
  "${row_gen_schemas_refined_outside_a_schema_kind_refuses_a_violating_value/BODY/red}" 1 \
  "gen-merge: a definition for option \`spool' is not of the expected type: must be positive" \
  "$tmpdir/gen-schemas-refined-outside-a-schema-kind-refuses-a-violating-value-red.err"
check "T5 gen-schemas-refined-outside-a-schema-kind-refuses-a-violating-value catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_gen_schemas_refined_outside_a_schema_kind_refuses_a_violating_value/BODY/caught}" 0 "" "$tmpdir/gen-schemas-refined-outside-a-schema-kind-refuses-a-violating-value-catch.err" 'CAUGHT'
