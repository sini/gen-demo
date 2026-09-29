# C100 -- a set union keeps every dependency edge. `combines.setUnion` collapses its elements
# under `==`, which ignores string context, so its union of `[ drvOnly ]` and `[ drvAll ]` (one
# `.drv` path, two contexts) is one element. That element carries the UNION of both contexts
# (den-hoag-kunjm F2, the quotient rule), as Nix's own concatenation would; prelude `unique` kept
# the walk-first element as it stood. `collisionDedupOn`'s shape with no dedup, so the union is
# the only collapse.
{
  genView,
  identityMark,
  diamondLabels,
  diamondCarrier,
  drvOnly,
  drvAll,
}:
{
  unionStorePath = genView.viewRelation {
    definition = genView.compositions.movement {
      channel = "selvage";
      relation = "gimp";
      root = "pewter";
      direction = "outbound";
      admission = diamondCarrier.labelWellFormedness;
      order = diamondCarrier.labelOrder;
      wellFormed = _: true;
      empty = [ ];
      tieSet = genView.tieSets.union;
      combine = genView.combines.setUnion { acc = true; };
      dedup = genView.dedups.none;
    };
    marks = _: [ ];
    orderMark = identityMark diamondLabels;
    graph = genView.scopeGraph {
      carrier = diamondCarrier;
      scopes = [
        "pewter"
        "grosgrain"
        "faille"
      ];
      edges = {
        tacks =
          id:
          if id == "pewter" then
            [
              "grosgrain"
              "faille"
            ]
          else
            [ ];
      };
      data = [
        {
          scope = "grosgrain";
          relation = "gimp";
          datum = [ drvOnly ];
        }
        {
          scope = "faille";
          relation = "gimp";
          datum = [ drvAll ];
        }
      ];
    };
  };
}
