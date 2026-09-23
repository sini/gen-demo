# `registry-split-key-refuses` — C4b, den-hoag-2vzn. Named for `registry` and not for `movement`,
# because `compositions.movement`'s key is a constant and cannot reach the spanning refusal at all.
# `splitKeyed` reads the diamond's own residual admission state as its competition key, so the one
# authored element at `grosgrain` survives under two keys and refuses catchably, by name — live
# control in the same cell: the identical declaration keyed on `c.scope` instead evaluates and
# carries exactly one contribution.
#
# registry-split-key-refuses -- named for `registry` and not for `movement`,
# because it declares `compositions.registry`: movement's key is a constant and
# cannot reach the spanning refusal at all, so a cell named `movement-...` would
# misname its own subject, which is the shape this library refuses elsewhere.
# `splitKeyed` reads the diamond's own residual admission state as its competition
# key, so the one authored element at `grosgrain` survives under two different
# keys and refuses BY NAME, catchably -- the refusal idiom is gen-demo's own,
# referenced rather than invented (`frayed-dangling-includes-refused` above).
# Live control in the same cell: the identical declaration keyed on `c.scope`
# instead evaluates, because both arrivals share one producer scope, and carries
# exactly one contribution.
{
  asserts,
  diamondCarrier,
  diamondGraph,
  diamondLabels,
  genView,
  identityMark,
  splitKeyed,
}:
{
  construct = [ "C4b" ];
  check = asserts (
    !(builtins.tryEval (builtins.deepSeq splitKeyed.value splitKeyed.value)).success
    && (
      let
        splitKeyedControl = genView.viewRelation {
          definition = genView.compositions.registry {
            channel = "selvage";
            relation = "gimp";
            root = "pewter";
            direction = "outbound";
            admission = diamondCarrier.labelWellFormedness;
            order = diamondCarrier.labelOrder;
            wellFormed = _: true;
            empty = [ ];
            tieSet = genView.tieSets.union;
            combine = genView.combines.listAppend;
            dedup = genView.dedups.none;
            entityOf = c: c.scope;
          };
          marks = _: [ ];
          orderMark = identityMark diamondLabels;
          graph = diamondGraph;
        };
      in
      (builtins.tryEval (builtins.deepSeq splitKeyedControl.value splitKeyedControl.value)).success
      && builtins.length splitKeyedControl.contributions == 1
    )
  );
}
