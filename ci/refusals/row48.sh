# shellcheck shell=bash
# ── row 48 -- a hand-built unit carrying the genuine tag is re-checked at intake and refused by
#    name (gen-view uw098; p79do Q1: an element tag is a CLAIM, ADR-0025 item 1) ──
# A one-unit schedule never reads a unit's fields, so a unit forged with `// { mode = … }` was
# ADMITTED and answered `["hem"]`. gen-view's intake now re-checks the element's structural fields
# and refuses the forged mode by name. Row 38's pewter/grosgrain declaration; the arms differ by the
# unit's mode alone. The unplanted arm asserts the answer, so a library refusing every unit cannot
# pass it, and the catchable arm is the one that measures item 1 (row 33's form).
row48='let
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
    mode = "merge";
  } // { mode = MODE; };
in BODY'
row48unplanted="${row48/MODE/\"merge\"}"
row48planted="${row48/MODE/\"sideways\"}"
check "T5 row48 unplanted (a genuine unit; the schedule is the assertion)" \
  "${row48unplanted/BODY/builtins.toJSON (genView.accumulatorOrder { inherit units; \})}" 0 "" \
  "$tmpdir/row48-green.err" '["hem"]'
check "T5 row48 planted   (a forged unit mode, refused by name at intake)" \
  "${row48planted/BODY/builtins.toJSON (genView.accumulatorOrder { inherit units; \})}" 1 \
  "gen-view.accumulatorRelation: field 'units.mode' is \"sideways\", which is not one of the declared arms" \
  "$tmpdir/row48-red.err"
check "T5 row48 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row48planted/BODY/if (builtins.tryEval (builtins.deepSeq (genView.accumulatorOrder { inherit units; \}) true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row48-catch.err" 'CAUGHT'
