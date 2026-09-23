# ── C12 — a derived product graph, and a policy-stratum promotion (ADR-0016 rulings 1
# and 2; gen-product) — computed ahead of C1 and C5 because its promoted node joins C1's
# node set and its promoted edges join C2's edge set, the same "one graph" discipline C5's
# own dynamic edge already follows.
{ genGraph, genProduct }:
let
  thimbleProductGraph = genGraph.mkGraph {
    edges = [
      {
        from = "pewter";
        to = "damask";
      }
    ];
  };
  bobbinProductGraph = genGraph.mkGraph {
    edges = [
      {
        from = "grosgrain";
        to = "faille";
      }
    ];
  };
  seamSpace = genProduct.productN "cartesian" [
    {
      dim = "thimble";
      graph = thimbleProductGraph;
      key = i: i;
      entryOf = i: i;
    }
    {
      dim = "bobbin";
      graph = bobbinProductGraph;
      key = i: i;
      entryOf = i: i;
    }
  ];
  seamCell = genProduct.cell seamSpace {
    thimble = "pewter";
    bobbin = "grosgrain";
  };
  # ★ THE HEAD, THE RELATA AND THE EDGE LABELS ARE ALL READ OFF THE COORDINATE — never
  # restated as literals. Oracle 3 row C12c is the guard that catches a literal in this spot.
  seamCoords = seamSpace.product.coordsOf seamCell;
  seamHead = "seam:${seamCoords.thimble}:${seamCoords.bobbin}";
in
{
  inherit
    thimbleProductGraph
    bobbinProductGraph
    seamSpace
    seamCell
    seamCoords
    seamHead
    ;
}
