# `walk-store-named-scope` — C46, den-hoag-u9k7j. gen-graph keys a caller's node names by their
# text, so a labeled graph over `pewter` and two scopes named `baseNameOf` of `hello` and `jq` is
# walked `contains*` from `pewter`: it answers all three nodes, the deepest path ends at the `jq`
# scope, the answered names keep their context, and the graph orders. The walk used to abort with `…
# is not allowed to refer to a store path`.
#
# C46 -- den-hoag-u9k7j. Live control: movement-dedup-equality.
{
  asserts,
  genGraph,
  helloScope,
  jqScope,
  storeNamedPaths,
  storeNamedReached,
  storeNamedWalk,
}:
{
  construct = [ "C46" ];
  check = asserts (
    let
      deepest = (builtins.elemAt storeNamedPaths 2).node;
    in
    builtins.length storeNamedReached == 3
    && builtins.elem helloScope storeNamedReached
    && builtins.any builtins.hasContext storeNamedReached
    && deepest == jqScope
    && builtins.hasContext deepest
    && (genGraph.topoOrder (genGraph.forgetLabels storeNamedWalk)).ok
  );
}
