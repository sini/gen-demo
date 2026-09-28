# C46 -- a walk over scopes named after packages. gen-graph keys a caller's node names by
# their text (den-hoag-u9k7j), so a labeled graph whose scopes are `baseNameOf` of two
# packages is walked, and every node it answers keeps its context. C2's idiom (`lg`,
# `tacked`) over store-named scopes.
{ genGraph, pkgs }:
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
  storeNamedWalk =
    genGraph.labeledFrom
      {
        contains = id: map (e: e.to) (builtins.filter (e: e.from == id) storeNamedContains);
      }
      [
        "pewter"
        helloScope
        jqScope
      ];
  storeNamedFollow = genGraph.regex.star (genGraph.regex.lit "contains");
  storeNamedReached =
    genGraph.query
      {
        mode = "all";
      }
      {
        graph = storeNamedWalk;
        from = "pewter";
        follow = storeNamedFollow;
      };
  storeNamedPaths =
    genGraph.query
      {
        mode = "paths";
      }
      {
        graph = storeNamedWalk;
        from = "pewter";
        follow = storeNamedFollow;
      };
in
{
  inherit
    helloScope
    jqScope
    storeNamedContains
    storeNamedWalk
    storeNamedFollow
    storeNamedReached
    storeNamedPaths
    ;
}
