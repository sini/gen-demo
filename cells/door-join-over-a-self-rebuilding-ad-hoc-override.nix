# `door-join-over-a-self-rebuilding-ad-hoc-override` — den-hoag-kr84r. A nixpkgs v2 record with an ad-hoc `check`,
# imported through `mkOptionType` and declared after a gen container, is judged at the join nixpkgs' engine asks the
# door for. `tangle`'s functor rebuilds the override at every payload, so its join is the override again and the option
# is refused, as the all-nixpkgs twin refuses it, in nixpkgs' `lib.evalModules` and in gen's own evaluation; declared
# before the `listOf` the join is the `listOf`'s, which the twin serves, and gen serves `[ 1 ]`. `knot`'s functor
# rebuilds the override at its own parameters only, so its join beside `listOf (enum [ "b" ])` is nixpkgs' coherent
# `listOf`: `[ "a" ]` and `[ "b" ]` are served as the twin serves them, and `[ "a" "a" ]`, inside `knot`'s own
# parameters and rejected by its check, is refused where the twin serves it only by dropping that check.
{
  asserts,
  genMerge,
  lib,
}:
let
  ft = lib.types;
  short = v: builtins.isList v && builtins.length v < 2;
  tangle = ft.mkOptionType {
    name = "listOf";
    check = short;
    merge = (ft.listOf ft.int).merge;
    functor = {
      name = "listOf";
      wrapped = null;
      payload.elemType = ft.int;
      type = _: tangle;
      binOp = a: b: a;
    };
    nestedTypes.elemType = ft.int;
  };
  ea = ft.enum [ "a" ];
  knot = ft.mkOptionType {
    name = "listOf";
    check = short;
    merge = (ft.listOf ea).merge;
    functor = (ft.listOf ea).functor // {
      type =
        p: if (p.elemType.functor.payload.values or null) == [ "a" ] then knot else ft.listOf p.elemType;
    };
    nestedTypes.elemType = ea;
  };
  np =
    types: v:
    (lib.evalModules {
      modules = map (type: { options.bobbin = lib.mkOption { inherit type; }; }) types ++ [
        { bobbin = v; }
      ];
    }).config.bobbin;
  gen =
    types: v:
    (genMerge.evalModuleTree { } (
      map (type: { options.bobbin = genMerge.mkOption { inherit type; }; }) types ++ [ { bobbin = v; } ]
    )).config.bobbin;
  attempt =
    f: types: v:
    builtins.tryEval (builtins.deepSeq (f types v) (f types v));
  refused =
    f: types: v:
    !(attempt f types v).success;
  served =
    f: types: v:
    (attempt f types v) == {
      success = true;
      value = v;
    };
  gl = genMerge.types.listOf ft.int;
  glB = genMerge.types.listOf (ft.enum [ "b" ]);
in
{
  construct = [ "v2-types-ad-hoc-check-override-is-refused" ];
  check = asserts (
    refused np [ (ft.listOf ft.int) tangle ] [ 1 ]
    && refused np [ gl (genMerge.mkOptionType tangle) ] [ 1 ]
    && refused np [ gl (genMerge.mkOptionType tangle) ] [ 1 2 ]
    && refused gen [ gl (genMerge.mkOptionType tangle) ] [ 1 ]
    && served np [ (genMerge.mkOptionType tangle) gl ] [ 1 ]
    && served gen [ (genMerge.mkOptionType tangle) gl ] [ 1 ]
    &&
      served np
        [
          (ft.listOf (ft.enum [ "b" ]))
          knot
        ]
        [ "a" ]
    && served np [ glB (genMerge.mkOptionType knot) ] [ "a" ]
    && served np [ glB (genMerge.mkOptionType knot) ] [ "b" ]
    && served gen [ glB (genMerge.mkOptionType knot) ] [ "b" ]
    && refused np [ glB (genMerge.mkOptionType knot) ] [ "a" "a" ]
    && refused gen [ glB (genMerge.mkOptionType knot) ] [ "a" "a" ]
  );
}
