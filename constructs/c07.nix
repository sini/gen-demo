# ── C7 — the well-definedness gate over the declared edge set (ADR-0008 §3, ADR-0030,
# ADR-0019; gen-view). C2's OWN declarations plus every CANDIDATE C5's program declares, ON OR
# OFF (den-hoag-6s1t (iii)): a static gate over-approximates, so a cycle through a policy edge
# that resolved off is still refused. `mkDeclaredEdges` admits and ignores the `label` field, so
# the corpus's edge records ride through unchanged. The gate publishes its verdict and the
# equations, never an order: its relation carries edges that resolve off (ADR-0019).
{
  genGraph,
  genValues,
  genView,
  registered,
  policyCandidates,
}:
let
  gateNodes = registered // policyCandidates.nodes; # the registration set plus every candidate node
  ref = genGraph.mkNodeRef { isRegistered = id: gateNodes ? ${id}; };
  contracted =
    es:
    genGraph.mkDeclaredEdges (
      map (
        e:
        e
        // {
          from = ref e.from;
          to = ref e.to;
        }
      ) es
    );
  gated = genView.boundedWellDefinedSchedule {
    nodes = builtins.attrNames gateNodes;
    declaredDependencies = contracted (genValues.declaredEdges ++ policyCandidates.edges); # NOT C2's `edges`
    equations = { }; # see OPEN 1
    admitsCycle = _: false; # nothing here is declared circular
  };
in
{
  inherit
    gateNodes
    ref
    contracted
    gated
    ;
}
