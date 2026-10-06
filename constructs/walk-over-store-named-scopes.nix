# C46 -- a walk over scopes named after packages. A caller's node names are keyed by their text
# (den-hoag-u9k7j), so an evaluated scope whose nodes are `baseNameOf` of two packages is walked by
# gen-scope's resolution calculus, and every node it answers keeps its context. C2's idiom
# (`edgeScope`, `tacked`) over store-named scopes. The same edges as a hand-built labelled record
# (data, ADR-0012's `{ nodes; labeledEdges; }`) are what gen-graph's structural algorithms read.
{
  genGraph,
  genScope,
  pkgs,
}:
let
  helloScope = baseNameOf pkgs.hello;
  jqScope = baseNameOf pkgs.jq;
  storeNamedContains = [
    {
      from = "pewter";
      to = helloScope;
    }
    {
      from = helloScope;
      to = jqScope;
    }
  ];
  storeNamedNodes = [
    "pewter"
    helloScope
    jqScope
  ];
  containsOf = id: map (e: e.to) (builtins.filter (e: e.from == id) storeNamedContains);
  storeNamedWalk = {
    nodes = storeNamedNodes;
    labeledEdges =
      id:
      map (t: {
        label = "contains";
        target = t;
      }) (containsOf id);
  };
  storeNamedEval = genScope.eval { parseParent = _: null; } {
    children = _: _: { };
    marks = _: _: [ ];
    edges-contains = _: containsOf;
  } (genScope.buildRoots { parentGraph = genScope.vertices storeNamedNodes; });
  storeNamedFollow = genScope.wellFormed {
    alphabet = [ "contains" ];
    expression = genScope.wfl.star (genScope.wfl.lit "contains");
  };
  storeNamedReached =
    map (a: a.node)
      (genScope.resolve {
        wf = storeNamedFollow;
        dataFilter = _: true;
      } storeNamedEval "pewter").answers;
  storeNamedPaths =
    (genScope.resolve {
      wf = storeNamedFollow;
      dataFilter = _: true;
      mode = "witnesses";
    } storeNamedEval "pewter").answers;
in
{
  inherit
    helloScope
    jqScope
    storeNamedContains
    storeNamedWalk
    storeNamedEval
    storeNamedFollow
    storeNamedReached
    storeNamedPaths
    ;
}
