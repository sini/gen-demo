# `kind-ancestors-in-order` — den-hoag-w523e. gen-schema's `ancestorsForKind` over one tree's chain
# and diamond: `selvage` reads `[ hem seam ]` (nearest first, root last), `seam` reads `[ ]`, and
# `gusset` reads `[ pleat tuck fold ]` (`fold` once, after both kinds inheriting it; `pleat` before
# `tuck` as `gusset` composes them). Every element is the `__kindAncestors` value at its mark
# (`kindEq`), and the kind NAME `"hem"` is refused, catchably. Red when an order is not a linear
# extension (a preorder reads `[ pleat fold tuck ]`), a shared ancestor repeats, or the door is missing.
{
  asserts,
  genSchema,
  orderedAncestorKinds,
}:
let
  k = orderedAncestorKinds;
  names = kind: map (a: a.kind) (genSchema.ancestorsForKind kind);
in
{
  construct = [ "kind-ancestors-in-order" ];
  check = asserts (
    names k.selvage == [
      "hem"
      "seam"
    ]
    && names k.seam == [ ]
    &&
      names k.gusset == [
        "pleat"
        "tuck"
        "fold"
      ]
    && builtins.all (a: genSchema.kindEq a k.gusset.__kindAncestors.${a.__mint.minted}) (
      genSchema.ancestorsForKind k.gusset
    )
    && !(builtins.tryEval (genSchema.ancestorsForKind "hem")).success
  );
}
