# shellcheck shell=bash
# ── row refined-given-a-bare-predicate -- gen-schema's `refined` given a refinement that is not a
#    `{ check; message; }` record refuses BY NAME at formation (den-hoag-ub19x; ADR-0025 item 1) ──
# A refinement is a predicate paired with the blame it reports. A bare predicate has no message to
# report, so `refined int positive` used to form and abort uncatchably ("expected a set but found a
# function") the first time a value met it. It now refuses where it is written, naming the fix. The
# unplanted arm is the record twin and asserts a STDOUT VALUE, so a `refined` that refused everything
# cannot pass it; the two arms differ by the refinement's spelling alone.
row_refined_given_a_bare_predicate='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  positive = v: v > 0;
  green = (schema.refined merge.types.int { check = positive; message = "must be positive"; }).name;
  red = (schema.refined merge.types.int positive).name;
  caught = if (builtins.tryEval red).success then "FORMED" else "CAUGHT";
in BODY'
check "T5 refined-given-a-bare-predicate unplanted (the record twin forms)" \
  "${row_refined_given_a_bare_predicate/BODY/green}" 0 "" "$tmpdir/refined-given-a-bare-predicate-green.err" 'int'
check "T5 refined-given-a-bare-predicate planted   (a bare predicate is refused by name at formation)" \
  "${row_refined_given_a_bare_predicate/BODY/red}" 1 \
  "gen-schema: refined: refinement 0 is of type \`lambda\`, not a refinement record" \
  "$tmpdir/refined-given-a-bare-predicate-red.err"
check "T5 refined-given-a-bare-predicate catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_refined_given_a_bare_predicate/BODY/caught}" 0 "" "$tmpdir/refined-given-a-bare-predicate-catch.err" 'CAUGHT'
