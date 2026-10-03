# `declaration-shadows-a-throwing-ancestor-default` — C172, den-hoag-gayc C1. `selvage` overrides
# `bolt`'s throwing `nap` default: under the declared key `group` and through `inherit'` the answer
# is "brushed" and the default is never forced. The strict key (`groupBy`, computed from the answer)
# forces it, and `weft`, which declares nothing, reaches it as its answer — both caught by `tryEval`,
# so laziness is shown to be shadowing and not skipping.
{
  asserts,
  napDeclared,
  napComputed,
  napInherited,
}:
let
  forced = x: !(builtins.tryEval (builtins.deepSeq x x)).success;
in
{
  construct = [ "C172" ];
  check = asserts (
    napDeclared "selvage" == "brushed"
    && napInherited "selvage" == "brushed"
    && forced (napComputed "selvage")
    && forced (napDeclared "weft")
    && forced (napInherited "weft")
  );
}
