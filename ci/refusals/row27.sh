# shellcheck shell=bash
# ── row 27 -- a definition composed with a graph over ANOTHER ALPHABET (gen-view og383) ──
# The seam M9 left open: `viewRelation` checked the orderMark against the definition's alphabet but
# never the definition's against the GRAPH's, so a composition over `{alpha, beta}` answered
# indistinguishably from the legitimate one over `{tacks, gathers}` -- same value, no refusal.
# ★ The mark is `D.identity`, the DEFINITION's own. Handing `G.identity` makes M9's orderMark guard
# fire instead and the row measures the wrong guard. The unplanted arm asserts a STDOUT VALUE, so a
# library that refused everything cannot pass it.
# ★ The graph's letters render `gathers, tacks` -- `quote` SORTS, so the declaration order below
# does not appear in the message.
row27='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  genScope = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.scope;
  world = letters: rec {
    labels = genView.edgeLabels { inherit letters; };
    admission = genScope.wellFormed { alphabet = labels.letters; expression = "(" + builtins.concatStringsSep "|" letters + ")*"; };
    order = genScope.labelOrder { alphabet = labels.letters; layers = map (l: [ l ]) letters; endOfPath = -1; };
    identity = genScope.labelOrder { alphabet = labels.letters; layers = [ letters ]; endOfPath = 0; };
  };
  G = world [ "tacks" "gathers" ];
  D = world [ ALPHABET ];
  carrier = genView.carrier {
    labels = G.labels;
    relations = genView.relations { names = [ "declares" ]; };
    relatumLabels = genView.relatumLabels { names = [ "warp" ]; };
    labelWellFormedness = G.admission;
    labelOrder = G.order;
    dataOrder = genView.dataOrder { channel = "settings"; keyOf = _: "settings"; };
  };
  graph = genView.scopeGraph {
    inherit carrier;
    scopes = [ "pewter" "grosgrain" ];
    edges = { tacks = id: if id == "pewter" then [ "grosgrain" ] else [ ]; gathers = _: [ ]; };
    data = [ { scope = "pewter"; relation = "declares"; datum = [ "from-pewter" ]; } ];
  };
in builtins.toJSON (map (c: c.datum) (genView.viewRelation { engine = genScope;
  definition = genView.compositions.movement {
    channel = "settings"; relation = "declares"; root = "pewter"; direction = "outbound";
    admission = D.admission; order = D.order;
    wellFormed = _: true; tieSet = genView.tieSets.union; empty = [ ];
    combine = genView.combines.listAppend; dedup = genView.dedups.none;
  };
  inherit graph;
  marks = _: [ ];
  orderMark = D.identity;
}).contributions)'
check "T5 row27 unplanted (definition over the graph's own alphabet)" \
  "${row27/ALPHABET/\"tacks\" \"gathers\"}" 0 "" "$tmpdir/row27-green.err" '[["from-pewter"]]'
check "T5 row27 planted   (definition over an alphabet the graph does not carry)" \
  "${row27/ALPHABET/\"alpha\" \"beta\"}" 1 \
  "gen-view.viewRelation: the definition's alphabet is not the graph's (alpha, beta vs gathers, tacks); one composition has one L" \
  "$tmpdir/row27-red.err"
