# `product-topo-order` — C12, den-hoag-4308w. A product IS an accessor-graph, so gen-graph's
# ordering door takes `seamSpace` whole — `parent`, `nodeData` and the product metadata included —
# and orders its cells producers-first. The graph record is open; the options come first.
# The cell asserts what the door promises and no more: every cell is emitted once, and after every
# cell it depends on. Which order two incomparable cells take is the door's pick, declared and not
# normative (gen-graph `topoOrder` clause 3, den-hoag-nz21), so it is not asserted here.
{
  asserts,
  genGraph,
  seamSpace,
}:
let
  inherit (builtins)
    all
    concatMap
    elemAt
    genList
    length
    listToAttrs
    sort
    ;
  result = genGraph.topoOrder { } seamSpace;
  inherit (result) order;
  position = listToAttrs (
    genList (i: {
      name = elemAt order i;
      value = i;
    }) (length order)
  );
  # every pair where cell `n` depends on cell `d`, read off the product's own accessor
  pairs = concatMap (n: map (d: { inherit n d; }) (seamSpace.edges n)) seamSpace.nodes;
  sorted = sort (a: b: a < b);
in
{
  construct = [ "C12" ];
  check = asserts (
    result.ok
    # membership: the order is a permutation of the product's cells
    && sorted order == sorted seamSpace.nodes
    # producers-first: every producer precedes its consumer
    && all (p: position.${p.d} < position.${p.n}) pairs
    # control: the predicate above is not vacuous; the cartesian product of two one-edge graphs
    # carries four dependency pairs
    && length pairs == 4
  );
}
