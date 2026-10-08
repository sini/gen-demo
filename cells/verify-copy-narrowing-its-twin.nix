# `verify-copy-narrowing-its-twin` — den-hoag-ndgcz, den-hoag-69w3d. A `//` copy that replaces a type's
# `verify` keeps the `check`, witness and relation of the type it was copied from, so gen's engine read it
# as that type: declared beside its twin, the copy's narrower verify was dropped and the value it rejects
# was served, and beside nixpkgs' `enum` the verdict depended on which declaration came first. gen-merge
# now owes the copy's verify to the meet and reads the copy as its completion in both orders: `weld`,
# which the copy rejects, is refused in every order beside the plain gen `enum`, beside nixpkgs' `enum`
# and beside a widening nixpkgs `enum`, while every member both admit is served, and the widening twin's
# own member `woad` is served as nixpkgs' union serves it. The same holds for a nullary leaf: a `spool`
# copy refusing more than eight is enforced beside `int`. The control: the copy declared alone refuses
# `weld`, and the plain pair serves it.
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
  spool = T.int;
  tight = spool // {
    verify = n: if builtins.isInt n && n > 8 then "more than eight" else spool.verify n;
  };
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
  # the verdict in both orders, collapsed: one element is order-independence
  both =
    a: b: v:
    lib.unique [
      (picks [ a b ] v)
      (picks [ b a ] v)
    ];
  twins = {
    gen = shade;
    nixpkgs = t.enum [
      "indigo"
      "madder"
      "weld"
    ];
    widening = t.enum [
      "madder"
      "woad"
    ];
  };
in
{
  construct = [ "a-verify-copy-narrowing-its-twin-is-enforced-in-every-order" ];
  check = asserts (
    picks [ dyed ] "weld" == "REFUSED"
    &&
      picks [
        shade
        shade
      ] "weld" == "weld"
    && lib.all (twin: both dyed twin "weld" == [ "REFUSED" ]) (builtins.attrValues twins)
    && both dyed twins.gen "indigo" == [ "indigo" ]
    && both dyed twins.nixpkgs "madder" == [ "madder" ]
    && both dyed twins.widening "madder" == [ "madder" ]
    && both dyed twins.widening "woad" == [ "woad" ]
    && both tight spool 12 == [ "REFUSED" ]
    && both tight spool 3 == [ 3 ]
  );
}
