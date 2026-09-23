# ── C7 — the well-definedness gate over the declared edge set (ADR-0008 §3, ADR-0030,
# ADR-0019; gen-view). C2's OWN declarations, contracted. `mkDeclaredEdges` admits and
# ignores the `label` field, so the corpus's edge records ride through unchanged.
{
  genGraph,
  genValues,
  genView,
  nodes,
}:
let
  ref = genGraph.mkNodeRef { isRegistered = id: nodes ? ${id}; };
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
    nodes = builtins.attrNames nodes; # the registration set
    declaredDependencies = contracted genValues.declaredEdges; # NOT C2's `edges`
    equations = { }; # see OPEN 1
    admitsCycle = _: false; # nothing here is declared circular
  };
  # THE CELL READS `gated`, NOT `contracted` — see the Check. A cell over the argument
  # forces gen-graph only (already reached) and adds nothing for gen-view.
  gatedSccs = (gated.condensation).sccs;
  gatedEdges = gated.edges "pewter";
in
{
  inherit
    ref
    contracted
    gated
    gatedSccs
    gatedEdges
    ;
}
