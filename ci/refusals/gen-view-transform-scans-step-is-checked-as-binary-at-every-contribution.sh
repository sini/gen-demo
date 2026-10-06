# shellcheck shell=bash
# ── row 118 -- gen-view `transform.scan`'s step is checked as BINARY at every contribution
#    (gen-view khmwt 9760c9b, den-hoag-khmwt) ──
# `scan`'s step is `accumulator -> contribution -> accumulator`; applied to the accumulator alone
# it must still return a FUNCTION, since the contribution is applied to that result next. A unary
# step returns a non-function there, and the second application used to abort uncatchably
# ("attempt to call something which is not a function but an integer"). The fix checks the
# intermediate result at every contribution and refuses by name before that application runs. The
# arms differ by the step alone; the unplanted arm asserts the running accumulation, so a library
# refusing every step cannot pass it.
row_gen_view_transform_scans_step_is_checked_as_binary_at_every_contribution='let
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
      scopes = [ "grosgrain" "pewter" ];
      edges.tacks = id: { pewter = [ "grosgrain" ]; }.${id} or [ ];
      data = [ { scope = "grosgrain"; relation = "gimp"; datum = [ "cambric" ]; } ];
    };
    marks = _: [ ];
    orderMark = genScope.labelOrder { alphabet = labels.letters; layers = [ [ "tacks" ] ]; endOfPath = 0; };
  };
  scanned = genView.transform.scan {
    inherit relation;
    name = "scanned";
    empty = [ ];
    f = STEP;
  };
in BODY'
row_gen_view_transform_scans_step_is_checked_as_binary_at_every_contributionunplanted="${row_gen_view_transform_scans_step_is_checked_as_binary_at_every_contribution/STEP/acc: c: acc ++ c.datum}"
row_gen_view_transform_scans_step_is_checked_as_binary_at_every_contributionplanted="${row_gen_view_transform_scans_step_is_checked_as_binary_at_every_contribution/STEP/acc: 42}"
check "T5 gen-view-transform-scans-step-is-checked-as-binary-at-every-contribution unplanted (a binary step; the running accumulation is the assertion)" \
  "${row_gen_view_transform_scans_step_is_checked_as_binary_at_every_contributionunplanted/BODY/builtins.toJSON (map (c: c.datum) scanned.contributions)}" 0 "" \
  "$tmpdir/gen-view-transform-scans-step-is-checked-as-binary-at-every-contribution-green.err" '[["cambric"]]'
check "T5 gen-view-transform-scans-step-is-checked-as-binary-at-every-contribution planted   (a unary step, refused by name)" \
  "${row_gen_view_transform_scans_step_is_checked_as_binary_at_every_contributionplanted/BODY/builtins.deepSeq scanned.contributions \"ADMITTED\"}" 1 \
  "gen-view.scan: the step, on the accumulator before contribution 0, returned 42; it is a binary step \`accumulator → contribution → accumulator\`, so it must return a function" \
  "$tmpdir/gen-view-transform-scans-step-is-checked-as-binary-at-every-contribution-red.err"
check "T5 gen-view-transform-scans-step-is-checked-as-binary-at-every-contribution catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_gen_view_transform_scans_step_is_checked_as_binary_at_every_contributionplanted/BODY/if (builtins.tryEval (builtins.deepSeq scanned.contributions \"ADMITTED\")).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/gen-view-transform-scans-step-is-checked-as-binary-at-every-contribution-catch.err" 'CAUGHT'
