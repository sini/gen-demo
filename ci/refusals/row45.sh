# shellcheck shell=bash
# ── row 45 -- every field of a unit is decided where the unit is built (gen-view rymxu) ──
# `unit` bound its `mode` check in a `let` and only inherited it, and `accumulatorOrder` over a
# ONE-unit schedule never reads `mode`, so `mode = "sideways"` answered `["hem"]` silently. The
# constructor now forces every field check at construction. The arms differ by MODE alone; the
# unplanted arm asserts the answer, so a library refusing every unit cannot pass it.
row45='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  labels = genView.edgeLabels { letters = [ "tacks" ]; };
  admission = genView.labelWellFormedness { alphabet = labels; expression = "tacks*"; };
  order = genView.labelOrder { alphabet = labels; layers = [ [ "tacks" ] ]; endOfPath = -1; };
  channel = genView.dataOrder { channel = "selvage"; keyOf = c: c.scope; };
  relation = genView.viewRelation {
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
    marks = _: [ ];
    orderMark = genView.labelOrder { alphabet = labels; layers = [ [ "tacks" ] ]; endOfPath = 0; };
  };
  units.hem = genView.unit {
    inherit relation;
    target = genView.placement.targets.root { scope = "pewter"; channel = "selvage"; };
    mode = MODE;
  };
  answer = genView.accumulatorOrder { inherit units; };
in BODY'
row45unplanted="${row45/MODE/\"merge\"}"
row45planted="${row45/MODE/\"sideways\"}"
check "T5 row45 unplanted (a declared mode; the schedule is the assertion)" \
  "${row45unplanted/BODY/builtins.toJSON answer}" 0 "" "$tmpdir/row45-green.err" '["hem"]'
check "T5 row45 planted   (an undeclared mode, refused by name at construction)" \
  "${row45planted/BODY/builtins.toJSON answer}" 1 \
  "gen-view.unit: field 'mode' is \"sideways\"" \
  "$tmpdir/row45-red.err"
check "T5 row45 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row45planted/BODY/if (builtins.tryEval (builtins.deepSeq answer true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row45-catch.err" 'CAUGHT'
