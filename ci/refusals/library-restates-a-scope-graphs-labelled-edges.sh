# shellcheck shell=bash
# ── row 57 -- the library restates a scope graph's labelled edges, never the `labeled` it carries
#    (gen-view cer8j; p79do Q1: an element tag is a CLAIM, ADR-0025 item 1) ──
# `scopeGraph` once published `labeled`, a gen-graph labelled graph derived from its `edges`,
# `scopes` and carrier, and `viewRelation` used to WALK it: a hand-built graph whose `labeled`
# answered no edges materialized an empty answer at exit 0, and one whose `labeledEdges` returned an
# int aborted past `tryEval`. The walk restates the edges from the checked fields, and the field
# itself retired (gen-view gayc U2f): a genuine graph carries no `labeled`, and a hand-built
# labelled record carried on one is inert (the forged arm answers exactly what the unplanted one
# does), and a forged `edges` meets the constructor's own law at the reading door (refused by
# name). Row 53's pewter/grosgrain declaration; the arms differ by the graph alone.
row_library_restates_a_scope_graphs_labelled_edges='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  genScope = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.scope;
  labels = genView.edgeLabels { letters = [ "tacks" ]; };
  admission = genScope.wellFormed { alphabet = labels.letters; expression = "tacks*"; };
  order = genScope.labelOrder { alphabet = labels.letters; layers = [ labels.letters ]; endOfPath = -1; };
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
  relation = genView.viewRelation { engine = genScope;
    definition = genView.viewDefinition {
      inherit channel admission order;
      relation = "gimp"; root = "pewter"; direction = "outbound"; wellFormed = _: true;
      distance = s: s.distance + 1;
      tieSet = genView.tieSets.union; empty = [ ];
      combine = genView.combines.listAppend; dedup = genView.dedups.none;
    };
    graph = GRAPH;
    marks = _: [ ];
    orderMark = genScope.labelOrder { alphabet = labels.letters; layers = [ labels.letters ]; endOfPath = 0; };
  };
in BODY'
row_library_restates_a_scope_graphs_labelled_edgesunplanted="${row_library_restates_a_scope_graphs_labelled_edges/GRAPH/genuine}"
row_library_restates_a_scope_graphs_labelled_edgesforged='genuine // { labeled = { nodes = genuine.scopes; labeledEdges = _: [ ]; }; }'
row_library_restates_a_scope_graphs_labelled_edgesinert="${row_library_restates_a_scope_graphs_labelled_edges/GRAPH/$row_library_restates_a_scope_graphs_labelled_edgesforged}"
row_library_restates_a_scope_graphs_labelled_edgesedges='genuine // { edges.tacks = 42; }'
row_library_restates_a_scope_graphs_labelled_edgesplanted="${row_library_restates_a_scope_graphs_labelled_edges/GRAPH/$row_library_restates_a_scope_graphs_labelled_edgesedges}"
check "T5 library-restates-a-scope-graphs-labelled-edges unplanted (a genuine graph; the answer is the assertion)" \
  "${row_library_restates_a_scope_graphs_labelled_edgesunplanted/BODY/builtins.toJSON relation.value}" 0 "" \
  "$tmpdir/library-restates-a-scope-graphs-labelled-edges-green.err" '["cambric"]'
check "T5 library-restates-a-scope-graphs-labelled-edges unplanted (a forged labeled answering no edges is inert: the same answer)" \
  "${row_library_restates_a_scope_graphs_labelled_edgesinert/BODY/builtins.toJSON relation.value}" 0 "" \
  "$tmpdir/library-restates-a-scope-graphs-labelled-edges-inert.err" '["cambric"]'
check "T5 library-restates-a-scope-graphs-labelled-edges unplanted (scopeGraph publishes no labeled field)" \
  "${row_library_restates_a_scope_graphs_labelled_edgesunplanted/BODY/builtins.toJSON (genuine ? labeled)}" 0 "" \
  "$tmpdir/library-restates-a-scope-graphs-labelled-edges-nolabeled.err" 'false'
check "T5 library-restates-a-scope-graphs-labelled-edges planted   (a forged edges accessor, refused by name at the reading door)" \
  "${row_library_restates_a_scope_graphs_labelled_edgesplanted/BODY/builtins.toJSON relation.value}" 1 \
  "gen-view.viewRelation: field 'graph.edges' carry the label 'tacks' bound to 42" \
  "$tmpdir/library-restates-a-scope-graphs-labelled-edges-red.err"
check "T5 library-restates-a-scope-graphs-labelled-edges catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_library_restates_a_scope_graphs_labelled_edgesplanted/BODY/if (builtins.tryEval (builtins.deepSeq relation.value true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/library-restates-a-scope-graphs-labelled-edges-catch.err" 'CAUGHT'
