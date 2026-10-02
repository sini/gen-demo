# shellcheck shell=bash
# ── row 136 -- gen-schema's `refined` outside a schema kind refuses a violating value, BY NAME
#    (den-hoag-refined-outside-kind-silent-1jlsq; ADR-0025 item 1) ──
# A refined type's refinements are part of its membership wherever it is used. In a plain option,
# outside any kind, `refined int positive` used to admit `-1`, because only a kind's pipeline read the
# refinement. It now refuses in gen-merge's words, naming the option and the refinement's message. The
# unplanted arm defines `4` on the same option and asserts a STDOUT VALUE, so a type that refused every
# value cannot pass it; the two arms differ by the defined value alone.
row136='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  read = v: toString (merge.evalModuleTree {
    modules = [
      { options.spool = merge.mkOption { type = schema.refined merge.types.int schema.refinements.positive; }; }
      { spool = v; }
    ];
  }).config.spool;
  green = read 4;
  red = read (-1);
  caught = if (builtins.tryEval red).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row136 unplanted (a member of the refined type is admitted)" \
  "${row136/BODY/green}" 0 "" "$tmpdir/row136-green.err" '4'
check "T5 row136 planted   (a value failing the refinement is refused by name)" \
  "${row136/BODY/red}" 1 \
  "gen-merge: a definition for option \`spool' is not of the expected type: must be positive" \
  "$tmpdir/row136-red.err"
check "T5 row136 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row136/BODY/caught}" 0 "" "$tmpdir/row136-catch.err" 'CAUGHT'
