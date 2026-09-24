# `inspect-reaches-over-the-corpus-graph` — C54. Reachability over this corpus's own graph, through
# the hub's `framework` bucket: `pewter` reaches `damask` over `tacks` only through `grosgrain`, a
# second hop the non-recursive edge query cannot see, so the pair — the closure beside the one-hop
# answer — is the assertion. The graph walk is the second arm and must agree. `faille` is the node
# no declared edge reaches, so it appears in no row whose source is another node. One `why` names
# the edge that carries the second hop. At a hub pinning a gen-inspect with no program route, the
# same query refuses `reaches` by name.
{
  asserts,
  c25Ir,
  inputs,
}:
let
  graph = inputs.gen.lib.substrate.graph;
  reaches = c25Ir.query "SELECT dst FROM reaches WHERE src = 'pewter' AND via = 'tacks' ORDER BY dst";
in
{
  construct = [ "C54" ];
  check = asserts (
    reaches == [
      { dst = "damask"; }
      { dst = "grosgrain"; }
      { dst = "pewter"; }
    ]
    # …the non-recursive fragment, same question: the second hop is what recursion adds
    &&
      c25Ir.query "SELECT dst FROM edge WHERE src = 'pewter' AND label = 'tacks'" == [
        { dst = "grosgrain"; }
      ]
    # the graph walk, `tacks*` from pewter, agrees
    &&
      map (d: { inherit d; }) (
        builtins.sort builtins.lessThan (
          graph.query {
            graph = c25Ir.facts.graph;
            from = "pewter";
            follow = graph.regex.star (graph.regex.lit "tacks");
          }
        )
      ) == map (r: { d = r.dst; }) reaches
    &&
      builtins.filter (r: r.dst == "faille" && r.src != "faille") (
        c25Ir.query "SELECT src, dst FROM reaches WHERE via = '*'"
      ) == [ ]
    &&
      map (d: d.rule.pos) (c25Ir.why "reaches:tacks:pewter:damask").derivations == [
        [
          "reaches:tacks:pewter:grosgrain"
          "tacks:grosgrain:damask"
        ]
      ]
  );
}
