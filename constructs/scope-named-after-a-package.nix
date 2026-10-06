# C45 -- a scope named after a package. `baseNameOf pkgs.hello` carries string context;
# gen-view keys it by its text, so the datum filed there is read back, and the entry's
# scope and datum keep their context. A non-walking read: a view over store-named scopes
# still aborts in gen-graph (den-hoag-u9k7j).
{
  diamondCarrier,
  genView,
  pkgs,
}:
let
  storeNamedScope = baseNameOf pkgs.hello;
  storeNamedGraph = genView.scopeGraph {
    carrier = diamondCarrier;
    scopes = [
      "pewter"
      storeNamedScope
    ];
    edges = {
      tacks = _: [ ];
    };
    data = [
      {
        scope = storeNamedScope;
        relation = "gimp";
        datum = [ pkgs.hello ];
      }
    ];
  };
  storeNamedEntries = genView.relationEntries {
    graph = storeNamedGraph;
    scope = storeNamedScope;
    relation = "gimp";
    wellFormed = _: true;
  };
in
{
  inherit storeNamedScope storeNamedGraph storeNamedEntries;
}
