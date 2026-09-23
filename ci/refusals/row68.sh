# shellcheck shell=bash
# ── row 68 -- a caller function's RESULT is refused BY NAME where gen-graph reads it
#    (gen-graph den-hoag-pqp4z; ADR-0025 item 1: a caller-supplied function owes a door per failure mode) ──
# `queryArrivals` applies the caller's `advance` at every step and carries its result as the arrival's
# `distance`. A non-int result used to be carried into the answer at exit 0 -- a silent wrong answer, so
# the planted `advance` arm is the one that matters: it is now refused where the distance is read. A
# `where` returning a non-bool used to abort past `tryEval` ("expected a Boolean"); it is now refused by
# the surface that applied it. The unplanted arm asserts the distances, and the catchable arm is row 33's form.
row68='let
  genGraph = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.graph;
  graph = genGraph.labeledFrom {
    nodes = [ "pewter" "faille" "grosgrain" ];
    perLabel.tacks = id: { pewter = [ "faille" ]; faille = [ "grosgrain" ]; }.${id} or [ ];
  };
  follow = genGraph.regex.star (genGraph.regex.lit "tacks");
  distances = map (a: a.distance) (genGraph.queryArrivals { inherit graph follow; from = "pewter"; advance = ADVANCE; });
  reached = genGraph.query { inherit graph follow; from = "pewter"; where = WHERE; };
in BODY'
row68ok="${row68/ADVANCE/s: s.distance + 1}"
row68ok="${row68ok/WHERE/_: true}"
row68far="${row68/ADVANCE/_: \"far\"}"
row68far="${row68far/WHERE/_: true}"
row68int="${row68/ADVANCE/s: s.distance + 1}"
row68int="${row68int/WHERE/_: 1}"
check "T5 row68 unplanted (a lawful advance and where; the distances are the assertion)" \
  "${row68ok/BODY/builtins.toJSON distances}" 0 "" \
  "$tmpdir/row68-green.err" '[0,1,2]'
check "T5 row68 planted   (a non-int advance, refused by name where the distance is read)" \
  "${row68far/BODY/builtins.toJSON distances}" 1 \
  'gen-graph.queryArrivals: advance on the step "pewter" -tacks-> "faille" returned a string, not an int, the distance after the step' \
  "$tmpdir/row68-red-advance.err"
check "T5 row68 planted   (a non-bool where, refused by name at query)" \
  "${row68int/BODY/builtins.toJSON reached}" 1 \
  'gen-graph.query: where "pewter" returned a int, not a bool' \
  "$tmpdir/row68-red-where.err"
check "T5 row68 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row68far/BODY/if (builtins.tryEval (builtins.deepSeq distances true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row68-catch.err" 'CAUGHT'
