# `frayed-dangling-includes-refused` — den-hoag-lk06. A local includes entry naming a key absent
# from the registry is refused by gen-link's `rewrite.originStamp`, catchably, rather than aborting
# past `tryEval` as an interpreter "attribute missing". gen-aspects synthesizes a key for any bare
# attrset placed in `includes` regardless of what the author wrote there, so an anonymous entry and
# a named-but-wrong-key one are one class; `frayed` links alone, never joining the mill/loom
# federation's sources, for the isolation reason given at its declaration.
#
# A local includes entry naming a key absent from BOTH `nodesByKey` and
# `refByToken` is refused by gen-link's `rewrite.originStamp`, catchably
# (den-hoag-lk06, ADR-0016 ruling 5). gen-aspects synthesizes a key for any bare
# attrset placed in `includes` regardless of what the author wrote there, so an
# anonymous entry and a named-but-wrong-key one are one class; `frayed` links
# ALONE — never joining `federated`'s sources above — for the isolation reason
# given at its declaration.
{
  asserts,
  frayed,
  genLink,
  selvageFacets,
}:
{
  construct = [ ];
  check = asserts (
    !(builtins.tryEval (
      builtins.deepSeq
        (genLink.link {
          sources = [
            {
              registry = frayed.config.aspects;
              keySemantics = selvageFacets;
              origin = [ "frayed" ];
            }
          ];
        }).manifest
        true
    )).success
  );
}
