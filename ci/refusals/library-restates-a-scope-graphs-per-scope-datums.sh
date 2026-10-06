# shellcheck shell=bash
# ── row 58 -- the library restates a scope graph's per-scope datums, never the `datumsAt` it carries
#    (gen-view dcvpi; p79do Q1: an element tag is a CLAIM, ADR-0025 item 1) ──
# `scopeGraph` publishes `datumsAt`, the per-scope index of its `data`, and `relationEntries` used to
# READ it: a hand-built graph whose `datumsAt` was empty materialized an empty answer at exit 0. The
# read now indexes `data` itself under the constructor's own law, so a forged `datumsAt` is inert
# (the second unplanted arm answers exactly what the first does), and a forged `data` meets that law
# at the reading door (the planted arm, refused by name). Row 57's pewter/grosgrain declaration; the
# arms differ by the graph alone.
row_library_restates_a_scope_graphs_per_scope_datums='let
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
row_library_restates_a_scope_graphs_per_scope_datumsunplanted="${row_library_restates_a_scope_graphs_per_scope_datums/GRAPH/genuine}"
row_library_restates_a_scope_graphs_per_scope_datumsforged='genuine // { datumsAt = { }; }'
row_library_restates_a_scope_graphs_per_scope_datumsinert="${row_library_restates_a_scope_graphs_per_scope_datums/GRAPH/$row_library_restates_a_scope_graphs_per_scope_datumsforged}"
row_library_restates_a_scope_graphs_per_scope_datumsdata='genuine // { data = genuine.data ++ [ { scope = "twill"; relation = "gimp"; datum = [ "crepe" ]; } ]; }'
row_library_restates_a_scope_graphs_per_scope_datumsplanted="${row_library_restates_a_scope_graphs_per_scope_datums/GRAPH/$row_library_restates_a_scope_graphs_per_scope_datumsdata}"
check "T5 library-restates-a-scope-graphs-per-scope-datums unplanted (a genuine graph; the answer is the assertion)" \
  "${row_library_restates_a_scope_graphs_per_scope_datumsunplanted/BODY/builtins.toJSON relation.value}" 0 "" \
  "$tmpdir/library-restates-a-scope-graphs-per-scope-datums-green.err" '["cambric"]'
check "T5 library-restates-a-scope-graphs-per-scope-datums unplanted (a forged datumsAt indexing nothing is inert: the same answer)" \
  "${row_library_restates_a_scope_graphs_per_scope_datumsinert/BODY/builtins.toJSON relation.value}" 0 "" \
  "$tmpdir/library-restates-a-scope-graphs-per-scope-datums-inert.err" '["cambric"]'
check "T5 library-restates-a-scope-graphs-per-scope-datums planted   (a forged datum off the graph's scopes, refused by name at the reading door)" \
  "${row_library_restates_a_scope_graphs_per_scope_datumsplanted/BODY/builtins.toJSON relation.value}" 1 \
  "gen-view.relationEntries: a datum of field 'graph.data' is filed at scope 'twill'" \
  "$tmpdir/library-restates-a-scope-graphs-per-scope-datums-red.err"
check "T5 library-restates-a-scope-graphs-per-scope-datums catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_library_restates_a_scope_graphs_per_scope_datumsplanted/BODY/if (builtins.tryEval (builtins.deepSeq relation.value true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/library-restates-a-scope-graphs-per-scope-datums-catch.err" 'CAUGHT'
