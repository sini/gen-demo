# `barestring-dangling-includes-refused` — den-hoag-zxgan. A bare string in `includes` naming no
# sibling key is a REFERENCE (den-hoag-2zjg1), never inline content, so it is refused catchably
# through the SAME `rewrite.originStamp` lookup `frayed-dangling-includes-refused.nix` exercises on
# the anonymous-`{ }` form — this cell mirrors that one's convention exactly, one shape substituted
# for the other. `frayedBareString` links alone, never joining the mill/loom federation's sources,
# for the same isolation reason `frayed` is kept apart (its declaration in `constructs/federated-packaged-subgraph.nix`).
{
  asserts,
  frayedBareString,
  genLink,
  selvageFacets,
}:
{
  construct = [ ];
  check = asserts (
    !(builtins.tryEval (
      builtins.deepSeq
        (genLink.link { } [
          {
            registry = frayedBareString.config.aspects;
            keySemantics = selvageFacets;
            origin = [ "frayedBareString" ];
          }
        ]).manifest
        true
    )).success
  );
}
