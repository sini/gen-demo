# `inspect-reaches-over-the-corpus-graph` — C54. Reachability over this corpus's own graph, through
# the hub's `framework` bucket: `pewter` reaches `damask` over `tacks` only through `grosgrain`, a
# second hop the non-recursive edge query cannot see, so the pair — the closure beside the one-hop
# answer — is the assertion. The graph walk, gen-scope's `resolve` over the IR's lifted scope, is the
# second arm and must agree. `faille` is the node
# no declared edge reaches, so it appears in no row whose source is another node. One `why` names
# the edge that carries the second hop. At a hub pinning a gen-inspect with no program route, the
# same query refuses `reaches` by name.
{
  asserts,
  c25Ir,
  genScope,
}:
let
  reaches = c25Ir.query "SELECT dst FROM reaches WHERE src = 'pewter' AND via = 'tacks' ORDER BY dst";
in
{
  construct = [ "reachability-over-the-corpus-graph" ];
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
          map (a: a.node)
            (genScope.resolve {
              wf = genScope.wellFormed {
                alphabet = c25Ir.facts.labels;
                expression = genScope.wfl.star (genScope.wfl.lit "tacks");
              };
              dataFilter = _: true;
            } c25Ir.facts.graph "pewter").answers
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
