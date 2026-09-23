# shellcheck shell=bash
# ── row 60 -- the library restates a combine's operation and unit from its whitelisted arm, never the
#    `op` and `unit` the element carries (gen-view 6vsvx; p79do Q1: an element tag is a CLAIM) ──
# `combineArms` is the ENFORCED whitelist of fold operations, and `op` is fixed by the arm. The fold
# used to READ the element's `op`: a `combines.listAppend` with its `op` replaced kept the tag, passed
# intake, and folded with the forger's operation at exit 0, a bypass of the whitelist. The fold now
# reads the arm's own record, so a forged `op` is inert (the second unplanted arm answers exactly
# what the first does), and a seed matched to a forged `unit` meets the arm's unit at the reading
# door (the planted arm, refused by name). Row 58's pewter/grosgrain graph; the arms differ by the
# definition alone.
row60='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  labels = genView.edgeLabels { letters = [ "tacks" ]; };
  admission = genView.labelWellFormedness { alphabet = labels; expression = "tacks*"; };
  order = genView.labelOrder { alphabet = labels; layers = [ labels.letters ]; endOfPath = -1; };
  channel = genView.dataOrder { channel = "selvage"; keyOf = c: c.scope; };
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
  genuine = genView.viewDefinition {
    inherit channel admission order;
    relation = "gimp"; root = "pewter"; direction = "outbound"; wellFormed = _: true;
    distance = s: s.distance + 1;
    tieSet = genView.tieSets.union; empty = [ ];
    combine = genView.combines.listAppend; dedup = genView.dedups.none;
  };
  relation = genView.viewRelation {
    definition = DEFINITION;
    inherit graph;
    marks = _: [ ];
    orderMark = genView.labelOrder { alphabet = labels; layers = [ labels.letters ]; endOfPath = 0; };
  };
in BODY'
row60unplanted="${row60/DEFINITION/genuine}"
row60forged='genuine // { combine = genuine.combine // { op = _: _: [ "moire" ]; }; }'
row60inert="${row60/DEFINITION/$row60forged}"
row60unit='genuine // { combine = genuine.combine // { unit = [ "moire" ]; }; empty = [ "moire" ]; }'
row60planted="${row60/DEFINITION/$row60unit}"
check "T5 row60 unplanted (a genuine definition; the answer is the assertion)" \
  "${row60unplanted/BODY/builtins.toJSON relation.value}" 0 "" \
  "$tmpdir/row60-green.err" '["cambric"]'
check "T5 row60 unplanted (a forged op on a whitelisted arm is inert: the same answer)" \
  "${row60inert/BODY/builtins.toJSON relation.value}" 0 "" \
  "$tmpdir/row60-inert.err" '["cambric"]'
check "T5 row60 planted   (a seed matched to a forged unit, refused by name against the arm's unit)" \
  "${row60planted/BODY/builtins.toJSON relation.value}" 1 \
  "gen-view.viewRelation: field 'definition.empty' is" \
  "$tmpdir/row60-red.err"
check "T5 row60 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row60planted/BODY/if (builtins.tryEval (builtins.deepSeq relation.value true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row60-catch.err" 'CAUGHT'
