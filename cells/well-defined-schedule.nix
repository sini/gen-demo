# `well-defined-schedule` — C7. `genView.boundedWellDefinedSchedule` over `config.declaredEdges`
# plus C5's candidates, read off the returned `gated` record, never of its argument: the gate
# admits the shipped corpus and returns its equations and NOTHING ORDER-SHAPED — its relation
# carries edges that may resolve off, so an order over it would observe them (ADR-0019,
# den-hoag-6s1t (iii)). A candidate cycle through an OFF edge is `gate-candidate-cycle-off`'s.
{
  asserts,
  gated,
}:
{
  construct = [ "C7" ];
  check = asserts (gated.equations == { } && builtins.attrNames gated == [ "equations" ]);
}
