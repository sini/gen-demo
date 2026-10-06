# shellcheck shell=bash
# ── row 47 -- a mark's `admits` verdict that is not a bool is refused by name (gen-view 0gpyq,
#    ADR-0025 item 1) ──
# gen-graph's `boundedBy` read a caller's `admits` verdict with `!`, so a non-bool verdict aborted
# uncatchably (`expected a Boolean but found an integer`). gen-view now checks each caller-supplied
# function's RESULT where it is consumed and refuses a malformed one by name. Row 38's pewter/grosgrain
# declaration; the arms differ by one mark's `admits` alone. The unplanted arm asserts the answer, so
# a library refusing every mark cannot pass it, and the catchable arm is the one that measures item 1
# (row 33's form).
row_marks_admits_verdict_that_is_not_a_bool='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  genScope = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.scope;
  labels = genView.edgeLabels { letters = [ "tacks" ]; };
  admission = genScope.wellFormed { alphabet = labels.letters; expression = "tacks*"; };
  order = genScope.labelOrder { alphabet = labels.letters; layers = [ [ "tacks" ] ]; endOfPath = -1; };
  channel = genView.dataOrder { channel = "selvage"; keyOf = c: c.scope; };
  relation = genView.viewRelation { engine = genScope;
    definition = genView.viewDefinition {
      inherit channel admission order;
      relation = "gimp"; root = "pewter"; direction = "outbound"; wellFormed = _: true;
      distance = s: s.distance + 1;
      tieSet = genView.tieSets.union; empty = [ ];
      combine = genView.combines.listAppend; dedup = genView.dedups.none;
    };
    graph = genView.scopeGraph {
      carrier = genView.carrier {
        inherit labels;
        relatumLabels = genView.relatumLabels { names = [ ]; };
        labelWellFormedness = admission; labelOrder = order; dataOrder = channel;
        relations = genView.relations { names = [ "gimp" ]; };
      };
      scopes = [ "grosgrain" "faille" "pewter" ];
      edges.tacks = id: { pewter = [ "faille" "grosgrain" ]; faille = [ "grosgrain" ]; }.${id} or [ ];
      data = [ { scope = "grosgrain"; relation = "gimp"; datum = [ "cambric" ]; } ];
    };
    marks = id: if id == "pewter" then [ { name = "hem"; admits = ADMITS; } ] else [ ];
    orderMark = genScope.labelOrder { alphabet = labels.letters; layers = [ [ "tacks" ] ]; endOfPath = 0; };
  };
in BODY'
row_marks_admits_verdict_that_is_not_a_boolunplanted="${row_marks_admits_verdict_that_is_not_a_bool/ADMITS/_: true}"
row_marks_admits_verdict_that_is_not_a_boolplanted="${row_marks_admits_verdict_that_is_not_a_bool/ADMITS/_: 42}"
check "T5 marks-admits-verdict-that-is-not-a-bool unplanted (an admitting mark; the answer is the assertion)" \
  "${row_marks_admits_verdict_that_is_not_a_boolunplanted/BODY/builtins.toJSON relation.value}" 0 "" \
  "$tmpdir/marks-admits-verdict-that-is-not-a-bool-green.err" '["cambric"]'
check "T5 marks-admits-verdict-that-is-not-a-bool planted   (a verdict that is not a bool, refused by name)" \
  "${row_marks_admits_verdict_that_is_not_a_boolplanted/BODY/builtins.toJSON relation.value}" 1 \
  "gen-view.viewRelation: a mark's 'admits' at scope 'pewter' for the label 'tacks' returned 42" \
  "$tmpdir/marks-admits-verdict-that-is-not-a-bool-red.err"
check "T5 marks-admits-verdict-that-is-not-a-bool catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_marks_admits_verdict_that_is_not_a_boolplanted/BODY/if (builtins.tryEval (builtins.deepSeq relation.value true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/marks-admits-verdict-that-is-not-a-bool-catch.err" 'CAUGHT'
