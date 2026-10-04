# ── C2 — edges, queried (ADR-0012, ADR-0019) ──
# `edges` IS the one graph: what the corpus declared, plus what C5's policy stratum admitted,
# plus C12's promoted coordinate edges.
{
  genScope,
  genSelect,
  genValues,
  nodes,
  pipingEdge,
  seamPromotion,
}:
let
  edges = genValues.declaredEdges ++ pipingEdge ++ seamPromotion.edges;
  byLabel = lbl: id: map (e: e.to) (builtins.filter (e: e.label == lbl && e.from == id) edges);
  # The one graph as an EVALUATED SCOPE, the structure gen-scope's resolution calculus walks: each
  # label `l` is the attribute `edges-l`, and every node declares its boundary marks, none
  # (ADR-0026; gen-authored, so stated rather than defaulted).
  edgeScope = genScope.eval { parseParent = _: null; } {
    children = _: _: { };
    marks = _: _: [ ];
    edges-tacks = _: byLabel "tacks";
    edges-gathers = _: byLabel "gathers";
    edges-piping = _: byLabel "piping";
  } (genScope.buildRoots { parentGraph = genScope.vertices (builtins.attrNames nodes); });
  follow =
    expression:
    builtins.sort builtins.lessThan (
      map (a: a.node)
        (genScope.resolve {
          wf = genScope.wellFormed {
            alphabet = [
              "tacks"
              "gathers"
              "piping"
            ];
            inherit expression;
          };
          dataFilter = _: true;
        } edgeScope "pewter").answers
    );
  # The named query: tacks*, then piping* — walks the derived label, so C5's edge changes what
  # this answers without the query ever mentioning `piping` as a declared thing.
  tacked = follow (
    genScope.wfl.seq [
      (genScope.wfl.star (genScope.wfl.lit "tacks"))
      (genScope.wfl.star (genScope.wfl.lit "piping"))
    ]
  );
  # The discriminator: `gathers` alone, so a label filter that stopped filtering is visible.
  gathered = follow (genScope.wfl.star (genScope.wfl.lit "gathers"));

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
    edgeScope
    tacked
    gathered
    thimbleKind
    selCtx
    selPewter
    selGrosgrain
    ;
}
