# `inspect-materializes-the-corpus-graph` — C25, den-hoag-graph-viz-viy69. gen-inspect, the roster's
# newest `framework` member, materializes this corpus's own declared graph into the one named IR its
# contract defines: four nodes over two kinds, three edges, every one carrying a declaration origin
# because this subject has no policy half. Asserted as a record rather than as a count, so a
# materialization that lost a kind and gained a node cannot pass the arithmetic. The library is
# reached at `inputs.gen.lib.framework.inspect` — the stratum bucket the hub publishes — and not as
# a module arg, because `flakeModules.genLibs` injects eight roster names and this is not one of
# them.
#
# C25 — gen-inspect over this corpus's own graph, through the hub's published
# `framework` bucket (den-hoag-graph-viz-viy69). The IR's figures are this corpus's
# own: four nodes over two kinds, three declared edges, every one carrying a
# declaration origin because this subject has no policy half. Asserted as a RECORD
# rather than as a count so a materialization that lost a kind and gained a node
# cannot pass the arithmetic.
{ asserts, c25Ir }:
{
  construct = [ "C25" ];
  check = asserts (
    {
      nodes = builtins.length c25Ir.facts.nodes;
      kinds = builtins.attrNames c25Ir.facts.kinds;
      edges = builtins.length c25Ir.facts.edges;
      labels = c25Ir.facts.labels;
      tables = builtins.attrNames c25Ir.facts.tables;
      declared = builtins.length (builtins.filter (e: e.origin.kind == "declaration") c25Ir.facts.edges);
    } == {
      nodes = 4;
      kinds = [
        "bobbin"
        "thimble"
      ];
      edges = 3;
      labels = [
        "gathers"
        "tacks"
      ];
      tables = [
        "bobbin"
        "edge"
        "thimble"
      ];
      declared = 3;
    }
  );
}
