# shellcheck shell=bash
# ── row 114 -- the record step's required field missing is refused by name, catchably, at the
#    record's own application (den-hoag-7gp66 P2 §p2.3.5, cells D2; ADR-0025 item 1) ──
# `ancestorsOf`'s first step is the accessor record's own door: an open record (R5), whose one
# required field is `parent`. A record without it used to abort on the native formal
# (`called without required argument 'parent'`), past `tryEval`. It is refused now by name when the
# record is applied, before any start id. The unplanted arm supplies `parent` and asserts the
# answer. Every arm is bound in the prelude, as row 113's are.
row_record_steps_required_field_missing='let
  genGraph = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.graph;
  answered = builtins.toJSON (genGraph.ancestorsOf { parent = id: if id == "twill" then "awl" else null; } "twill");
  missing = builtins.toJSON (genGraph.ancestorsOf { } "twill");
  caught = if (builtins.tryEval (builtins.seq (genGraph.ancestorsOf { }) null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 record-steps-required-field-missing unplanted (the accessor record with its parent answers)" \
  "${row_record_steps_required_field_missing/BODY/answered}" 0 "" "$tmpdir/record-steps-required-field-missing-green.err" '["awl"]'
check "T5 record-steps-required-field-missing planted   (the accessor record without its parent is refused by name)" \
  "${row_record_steps_required_field_missing/BODY/missing}" 1 \
  "gen-graph.ancestorsOf: required field 'parent' is missing (required: 'parent') (in prelude.checkRequired)" \
  "$tmpdir/record-steps-required-field-missing-red.err"
check "T5 record-steps-required-field-missing catchable  (the refusal is caught by tryEval at the record's application, not an abort)" \
  "${row_record_steps_required_field_missing/BODY/caught}" 0 "" "$tmpdir/record-steps-required-field-missing-catch.err" 'CAUGHT'
