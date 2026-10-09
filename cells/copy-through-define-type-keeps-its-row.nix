# `copy-through-define-type-keeps-its-row` — den-hoag-5kzqp. A `//` copy of a completed gen type handed to
# `defineType` was re-completed from its gen datum alone, so it lost the row its completion was built under
# (a gen `enum` published its caller's name with no payload) and every reader took it for a record of its
# own: beside a widening gen `enum` the union's own member was refused, and beside nixpkgs' `enum` every
# member was refused under nixpkgs' engine. The door now returns such a copy as it is, its narrower check
# published where nixpkgs reads one: `woad`, which only the widening twin admits, is served in both orders,
# `weld`, which the copy rejects, is refused, and the door's copy reads exactly as the raw copy does. Under
# nixpkgs' own `evalModules` the door's copy declared alone refuses `weld`, and declared after nixpkgs'
# `enum` (whose `typeMerge` nixpkgs then asks of the copy) refuses `weld` and serves `madder`.
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
  door = T.defineType dyed;
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
  foreign =
    tys: v:
    let
      p =
        (lib.evalModules {
          modules = map (ty: { options.dye = lib.mkOption { type = ty; }; }) tys ++ [ { dye = v; } ];
        }).config.dye;
      r = builtins.tryEval (builtins.deepSeq p p);
    in
    if r.success then r.value else "REFUSED";
in
{
  construct = [ "a-copy-through-define-type-keeps-its-row" ];
  check = asserts (
    both door widening "woad" == [ "woad" ]
    && both door widening "weld" == [ "REFUSED" ]
    && both door widening "madder" == [ "madder" ]
    && lib.all (v: both door widening v == both dyed widening v) [
      "indigo"
      "madder"
      "weld"
      "woad"
    ]
    && foreign [ door ] "weld" == "REFUSED"
    &&
      foreign [
        nixpkgsShade
        door
      ] "weld" == "REFUSED"
    &&
      foreign [
        nixpkgsShade
        door
      ] "madder" == "madder"
  );
}
