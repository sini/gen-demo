# shellcheck shell=bash
# ── row 114 -- the record step's required field missing is refused by name, catchably, at the
#    record's own application (den-hoag-7gp66 P2 §p2.3.5, cells D2; ADR-0025 item 1) ──
# `ancestorsOf opts` returns the accessor record's own door: an open record (R5), whose one
# required field is `parent`. `ancestorsOf { } { }` used to abort on the native formal
# (`called without required argument 'parent'`), past `tryEval`. It is refused now by name when the
# record is applied, before any start id. The unplanted arm supplies `parent` and asserts the
# answer. Every arm is bound in the prelude, as row 113's are.
row114='let
  genGraph = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.graph;
  answered = builtins.toJSON (genGraph.ancestorsOf { } { parent = id: if id == "twill" then "awl" else null; } "twill");
  missing = builtins.toJSON (genGraph.ancestorsOf { } { } "twill");
  caught = if (builtins.tryEval (builtins.seq (genGraph.ancestorsOf { } { }) null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row114 unplanted (the accessor record with its parent answers)" \
  "${row114/BODY/answered}" 0 "" "$tmpdir/row114-green.err" '["awl"]'
check "T5 row114 planted   (the accessor record without its parent is refused by name)" \
  "${row114/BODY/missing}" 1 \
  "gen-graph.ancestorsOf: required field 'parent' is missing (required: 'parent') (in prelude.checkRequired)" \
  "$tmpdir/row114-red.err"
check "T5 row114 catchable  (the refusal is caught by tryEval at the record's application, not an abort)" \
  "${row114/BODY/caught}" 0 "" "$tmpdir/row114-catch.err" 'CAUGHT'
