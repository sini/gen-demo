# ── C2 — edges, queried (ADR-0012, ADR-0019) ──
# `edges` IS the one graph: what the corpus declared, plus what C5's policy stratum admitted,
# plus C12's promoted coordinate edges.
{
  genGraph,
  genSelect,
  genValues,
  nodes,
  pipingEdge,
  seamPromotion,
}:
let
  edges = genValues.declaredEdges ++ pipingEdge ++ seamPromotion.edges;
  byLabel = lbl: id: map (e: e.to) (builtins.filter (e: e.label == lbl && e.from == id) edges);
  lg = genGraph.labeledFrom {
    nodes = builtins.attrNames nodes;
    perLabel = {
      tacks = byLabel "tacks";
      gathers = byLabel "gathers";
      piping = byLabel "piping";
    };
  };
  # The named query: tacks*, then piping* — walks the derived label, so C5's edge changes what
  # this answers without the query ever mentioning `piping` as a declared thing.
  tacked = genGraph.query {
    graph = lg;
    from = "pewter";
    follow = genGraph.regex.seq [
      (genGraph.regex.star (genGraph.regex.lit "tacks"))
      (genGraph.regex.star (genGraph.regex.lit "piping"))
    ];
  };
  # The discriminator: `gathers` alone, so a label filter that stopped filtering is visible.
  gathered = genGraph.query {
    graph = lg;
    from = "pewter";
    follow = genGraph.regex.star (genGraph.regex.lit "gathers");
  };

  # A second door on the same declarations: gen-select, over the heterogeneous union. The
  # adapter's default `kindFor` (`_: kind`) projects one constant kind across the union and the
  # `false` arm never appears (`gen-select/lib/adapters/registry.nix`); the explicit per-id
  # `kindFor` is required because `nodes` spans two registries.
  thimbleKind = genValues.schema.thimble;
  selCtx = genSelect.adapters.registry.mkContext {
    nodes = builtins.attrNames nodes;
    data = id: nodes.${id};
    parent = _: null;
    kind = thimbleKind;
    kindFor = id: if genValues.thimbles ? ${id} then thimbleKind else genValues.schema.bobbin;
  };
  selPewter = genSelect.matches (genSelect.kind thimbleKind) "pewter" selCtx;
  selGrosgrain = genSelect.matches (genSelect.kind thimbleKind) "grosgrain" selCtx;
in
{
  inherit
    edges
    byLabel
    lg
    tacked
    gathered
    thimbleKind
    selCtx
    selPewter
    selGrosgrain
    ;
}
