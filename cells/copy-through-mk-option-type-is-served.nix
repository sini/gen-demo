# `copy-through-mk-option-type-is-served` — den-hoag-r23mj. A `//` copy of a completed gen type handed to
# `mkOptionType` was imported as a record of its own, unminted, its relation rebuilt from the copy's functor, so
# beside a widening gen `enum` the value both declarations admit was refused in both orders, and beside nixpkgs'
# `enum` the copy's own member was refused in one order, where nixpkgs' engine serves each. The door now returns
# such a copy as it is, as `defineType` does: `madder`, which both declarations admit, and `woad`, which only the
# widening twin admits, are served in both orders, `weld`, which the copy rejects, is refused, and the door's copy
# reads exactly as the raw copy does beside either twin. It keeps its mark and its stale stamp, so gen's
# comparison still refuses it by name while the completion compares equal to itself.
{
  asserts,
  genMerge,
  lib,
}:
let
  T = genMerge.types;
  t = lib.types;
  shade = T.enum "shade" [
    "indigo"
    "madder"
    "weld"
  ];
  dyed = shade // {
    verify = v: if v == "weld" then "weld is not colourfast" else shade.verify v;
  };
  door = genMerge.mkOptionType dyed;
  widening = T.enum "vat" [
    "madder"
    "woad"
  ];
  nixpkgsShade = t.enum [
    "indigo"
    "madder"
    "weld"
  ];
  picks =
    tys: v:
    let
      p =
        (genMerge.evalModuleTree { } (
          map (ty: { options.dye = genMerge.mkOption { type = ty; }; }) tys ++ [ { dye = v; } ]
        )).config.dye;
      r = builtins.tryEval (builtins.deepSeq p p);
    in
    if r.success then r.value else "REFUSED";
  both =
    a: b: v:
    lib.unique [
      (picks [ a b ] v)
      (picks [ b a ] v)
    ];
  refused = e: !(builtins.tryEval (builtins.deepSeq e e)).success;
in
{
  construct = [ "a-copy-through-mk-option-type-is-served" ];
  check = asserts (
    both door widening "madder" == [ "madder" ]
    && both door widening "woad" == [ "woad" ]
    && both door widening "weld" == [ "REFUSED" ]
    && both door nixpkgsShade "madder" == [ "madder" ]
    &&
      lib.all
        (
          tw:
          lib.all (v: both door tw v == both dyed tw v) [
            "indigo"
            "madder"
            "weld"
            "woad"
          ]
        )
        [
          widening
          nixpkgsShade
        ]
    && refused (T.typeEq shade door)
    && T.typeEq shade shade
  );
}
