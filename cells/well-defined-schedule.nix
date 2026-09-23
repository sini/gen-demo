# `well-defined-schedule` — C7. `genView.boundedWellDefinedSchedule` over `config.declaredEdges`,
# read off fields of the returned `gated` record, never of its argument: the cyclic-SCC filter (`[
# ]`, over a real five-way partition) and the contracted accessor's own edge lookup (`gated.edges
# "pewter"`). A hand-written record of the same fields satisfies this cell byte-for- byte -- see
# Oracle 1b and `refusals` row 11 below.
#
# C7 — the well-definedness gate. Fields of `gated` ITSELF, never of
# `contracted` (that would force gen-graph only, already reached — gate v0's
# CONSTRUCTION-1). Forcing `gated.condensation` and `gated.edges` also runs
# gen-view's own door (`graph.isDeclaredEdges`), its cyclic-SCC filter and its
# `admitsCycle` application — none of which gen-graph performs.
{
  asserts,
  gatedEdges,
  gatedSccs,
}:
{
  construct = [ "C7" ];
  check = asserts (
    gatedSccs == [
      [ "damask" ]
      [ "faille" ]
      [ "seam:pewter:grosgrain" ]
      [ "grosgrain" ]
      [ "pewter" ]
    ]
    && (builtins.filter (scc: builtins.length scc > 1) gatedSccs) == [ ]
    &&
      gatedEdges == [
        "grosgrain"
        "damask"
      ]
  );
}
