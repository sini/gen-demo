# shellcheck shell=bash
# ── row 57 -- the library restates a scope graph's labelled edges, never the `labeled` it carries
#    (gen-view cer8j; p79do Q1: an element tag is a CLAIM, ADR-0025 item 1) ──
# `scopeGraph` publishes `labeled`, a gen-graph labelled graph derived from its `edges`, `scopes`
# and carrier, and `viewRelation` used to WALK it: a hand-built graph whose `labeled` answered no
# edges materialized an empty answer at exit 0, and one whose `labeledEdges` returned an int
# aborted past `tryEval`. The walk now restates the labelled graph from the checked fields, so a
# forged `labeled` is inert (the first planted arm answers exactly what the unplanted one does), and
# a forged `edges` meets the constructor's own law at the reading door (the second, refused by
# name). Row 53's pewter/grosgrain declaration; the arms differ by the graph alone.
row57='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  labels = genView.edgeLabels { letters = [ "tacks" ]; };
  admission = genView.labelWellFormedness { alphabet = labels; expression = "tacks*"; };
  order = genView.labelOrder { alphabet = labels; layers = [ labels.letters ]; endOfPath = -1; };
  channel = genView.dataOrder { channel = "selvage"; keyOf = c: c.scope; };
  genuine = genView.scopeGraph {
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
  relation = genView.viewRelation {
    definition = genView.viewDefinition {
      inherit channel admission order;
      relation = "gimp"; root = "pewter"; direction = "outbound"; wellFormed = _: true;
      distance = s: s.distance + 1;
      tieSet = genView.tieSets.union; empty = [ ];
      combine = genView.combines.listAppend; dedup = genView.dedups.none;
    };
    graph = GRAPH;
    marks = _: [ ];
    orderMark = genView.labelOrder { alphabet = labels; layers = [ labels.letters ]; endOfPath = 0; };
  };
in BODY'
row57unplanted="${row57/GRAPH/genuine}"
row57forged='genuine // { labeled = genuine.labeled // { labeledEdges = _: [ ]; }; }'
row57inert="${row57/GRAPH/$row57forged}"
row57edges='genuine // { edges.tacks = 42; }'
row57planted="${row57/GRAPH/$row57edges}"
check "T5 row57 unplanted (a genuine graph; the answer is the assertion)" \
  "${row57unplanted/BODY/builtins.toJSON relation.value}" 0 "" \
  "$tmpdir/row57-green.err" '["cambric"]'
check "T5 row57 unplanted (a forged labeled answering no edges is inert: the same answer)" \
  "${row57inert/BODY/builtins.toJSON relation.value}" 0 "" \
  "$tmpdir/row57-inert.err" '["cambric"]'
check "T5 row57 planted   (a forged edges accessor, refused by name at the reading door)" \
  "${row57planted/BODY/builtins.toJSON relation.value}" 1 \
  "gen-view.viewRelation: field 'graph.edges' carry the label 'tacks' bound to 42" \
  "$tmpdir/row57-red.err"
check "T5 row57 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row57planted/BODY/if (builtins.tryEval (builtins.deepSeq relation.value true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row57-catch.err" 'CAUGHT'
