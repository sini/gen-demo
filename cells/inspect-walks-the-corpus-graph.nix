# `inspect-walks-the-corpus-graph` — C25, den-hoag-graph-viz-viy69. `faille` is the node no declared
# edge reaches, which is this corpus's own stated fact about itself and what makes C5's dynamic edge
# observable elsewhere. The WALK is asked rather than the edge list: the IR's `perLabel` is an
# attrset of accessors and a wrong shape fails only on application, so a materialization that built
# the wrong one reds here and nowhere earlier. `pewter` is the control, reaching on both labels.
#
# C25 — `faille` is the node NO declared edge reaches, which is this corpus's
# own stated fact about itself (it is what makes C5's dynamic edge observable). The
# walk is asked, not the edge list: an accessor-shaped `perLabel` fails only on
# APPLICATION, so a materialization that built the wrong shape reds here and
# nowhere earlier. `pewter` is the control — it reaches on both labels.
{ asserts, c25Ir }:
{
  construct = [ "C25" ];
  check = asserts (
    c25Ir.facts.graph.labeledEdges "faille" == [ ]
    &&
      c25Ir.facts.graph.labeledEdges "pewter" == [
        {
          label = "gathers";
          target = "damask";
        }
        {
          label = "tacks";
          target = "grosgrain";
        }
      ]
    && builtins.length c25Ir.facts.graph.nodes == 4
  );
}
