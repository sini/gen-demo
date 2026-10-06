{
  title = "a walk over store-named scopes";
  adr = "0025 item 1";
  what = "`walk-store-named-scope`: a labeled graph over scopes named `baseNameOf pkgs.hello` and `baseNameOf pkgs.jq` is walked `contains*` from `pewter`; every answered name keeps its context and the graph orders, where the walk used to abort (`… is not allowed to refer to a store path`)";
}
