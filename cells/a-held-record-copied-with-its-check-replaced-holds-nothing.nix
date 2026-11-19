# `a-held-record-copied-with-its-check-replaced-holds-nothing` — den-hoag-redeclaration-beside-foreign-slope-vhcac (c4).
# `x` and `y` each declare `listOf int` beside a nixpkgs `listOf`, and declared together their element is a held record
# `z` that states it holds `x`'s element `px`. Declared together, `[ 0 ]` is refused on both engines (`x` refuses it).
# A `//` copy of `z` with its check replaced is not the record that statement was made for, so `px` beside it still
# owes its check: `[ 0 ]` is refused on gen's engine. A copy keeping check and fold but stating a v2 `merge` is folded
# by that merge, so it too holds nothing. W (one container redeclared N times beside a foreign one) serves `[ 2 ]` and
# refuses `[ 0 ]` at N = 2, 4 and 8.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  g = genMerge.types;
  served =
    eval: mkOption: types: vs:
    let
      r = builtins.tryEval (
        let
          x =
            (eval (map (type: { options.o = mkOption { inherit type; }; }) types ++ map (v: { o = v; }) vs))
            .config.o;
        in
        builtins.deepSeq x x
      );
    in
    if r.success then { value = r.value; } else null;
  gen = served (modules: genMerge.evalModuleTree { } modules) genMerge.mkOption;
  ref = served (modules: lib.evalModules { inherit modules; }) lib.mkOption;
  optType =
    tys:
    (genMerge.evalModuleTree { } (map (ty: { options.o = genMerge.mkOption { type = ty; }; }) tys))
    .options.o.type;
  x = optType [
    (g.listOf g.int)
    (g.listOf t.ints.positive)
  ];
  y = optType [
    (g.listOf g.int)
    (g.listOf (t.ints.between 0 10))
  ];
  px = x.nestedTypes.elemType;
  z =
    (optType [
      x
      y
    ]).nestedTypes.elemType;
  checkTrue = z // {
    check = _: true;
    typeMerge = _: checkTrue;
  };
  head = _: defs: (builtins.head defs).value;
  mergeV2 = z // {
    merge = {
      __functor = _: head;
      v2 = args: {
        value = (builtins.head args.defs).value;
        headError = null;
        valueMeta = { };
      };
    };
    typeMerge = _: mergeV2;
  };
  w = n: builtins.genList (i: if i == n - 1 then g.listOf t.ints.positive else g.listOf g.int) n;
in
{
  construct = [ "a-held-record-copied-with-its-check-replaced-holds-nothing" ];
  check = asserts (
    gen [ x y ] [ [ 0 ] ] == null
    && ref [ x y ] [ [ 0 ] ] == null
    && gen [ px checkTrue ] [ 0 ] == null
    && gen [ px mergeV2 ] [ 0 ] == null
    && gen [ px checkTrue ] [ 5 ] == { value = 5; }
    && builtins.all (n: gen (w n) [ [ 2 ] ] == { value = [ 2 ]; } && gen (w n) [ [ 0 ] ] == null) [
      2
      4
      8
    ]
  );
}
