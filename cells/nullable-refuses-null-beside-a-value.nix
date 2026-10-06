# `nullable-refuses-null-beside-a-value` — C162, den-hoag-azdne. A gen `nullOr` defined null in one
# module and a value in another is refused catchably, as nixpkgs' `nullOr` refuses the same two
# definitions ("defined both null and not null"). The controls serve on both engines alike: every
# definition null, a null out-prioritised by `mkDefault`, and a null discharged by `mkIf false`.

{
  asserts,
  genMerge,
  lib,
  nullableHem,
  nullableHemNixpkgs,
}:

let
  both = defs: nullableHem (defs genMerge) == nullableHemNixpkgs (defs lib);
in
{
  construct = [ "nullable-refuses-null-beside-a-value" ];
  check = asserts (
    !(nullableHem [
      null
      5
    ]).success
    && both (_: [
      null
      5
    ])
    && both (_: [
      null
      null
    ])
    && both (M: [
      (M.mkDefault null)
      5
    ])
    && both (M: [
      (M.mkIf false null)
      5
    ])
  );
}
