# `product-topo-order` — C12, den-hoag-4308w. A product IS an accessor-graph, so gen-graph's
# ordering door takes `seamSpace` whole — `parent`, `nodeData` and the product metadata included —
# and orders its cells producers-first. The graph record is open; the options come first.
{
  asserts,
  genGraph,
  genProduct,
  seamSpace,
}:
{
  construct = [ "C12" ];
  check = asserts (
    map (
      cid:
      let
        c = genProduct.coordsOf seamSpace cid;
      in
      "${c.thimble}*${c.bobbin}"
    ) (genGraph.topoOrder { } seamSpace).order == [
      "damask*faille"
      "damask*grosgrain"
      "pewter*faille"
      "pewter*grosgrain"
    ]
  );
}
