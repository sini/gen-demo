# ── C59 — a restricted product and its materialized membership index (ADR-0012 clause 2;
# gen-product, den-hoag-bksu). A needle × thread product restricted by one relation: the corpus's
# first `restrict`. The restriction record the product publishes carries its own membership index,
# which every point test (`cell`, `edges`) reads instead of re-deriving a key list per probe.
{ genGraph, genProduct }:
let
  needleGraph = genGraph.mkGraph {
    edges = [
      {
        from = "sharp";
        to = "betweens";
      }
    ];
  };
  threadGraph = genGraph.mkGraph {
    edges = [
      {
        from = "silk";
        to = "linen";
      }
    ];
  };
  threadingSpace = genProduct.productN "cartesian" [
    {
      dim = "needle";
      graph = needleGraph;
      key = i: i;
      entryOf = i: i;
    }
    {
      dim = "thread";
      graph = threadGraph;
      key = i: i;
      entryOf = i: i;
    }
  ];
  threading = genProduct.restrict threadingSpace {
    relations = [
      {
        dims = [
          "needle"
          "thread"
        ];
        pairs = [
          {
            needle = "sharp";
            thread = "silk";
          }
          {
            needle = "betweens";
            thread = "linen";
          }
        ];
      }
    ];
  };
in
{
  inherit threadingSpace threading;
}
