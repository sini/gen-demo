# `enum-redeclared-across-names-is-nixpkgs-union` — den-hoag-n8cpq item 2 (owner ruling OQ1, arm
# (b)). One option `weave` is declared by gen `enum "weave" [ "sateen" ]`, gen `enum "loom"
# [ "twill" ]` and nixpkgs `enum [ "satin" ]`. nixpkgs' `enum` has no name and unions any two, and a
# gen `enum` now does the same, under any two names and beside nixpkgs' own, so in all six orders on
# both engines the option equals its nixpkgs-only twin at each member, description (the union, in
# order) included. The twin is read in nixpkgs' own engine for both engines' rows, so a fold gen's
# engine gets wrong for the twin too cannot pass as equal. A planted `bobbin`, in no declared enum,
# is refused in all twelve. It used to refuse every redeclaration under two names.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  g = genMerge.types;
  engines = {
    gen = genMerge.evalModuleTree { };
    ref = modules: lib.evalModules { inherit modules; };
  };
  read =
    eng: types: v:
    let
      r = builtins.tryEval (
        let
          o = engines.${eng} (
            map (type: { options.weave = lib.mkOption { inherit type; }; }) types ++ [ { weave = v; } ]
          );
          a = {
            inherit (o.options.weave.type) description;
            value = o.config.weave;
          };
        in
        builtins.deepSeq a a
      );
    in
    if r.success then r.value else null;
  mixed = [
    (g.enum "weave" [ "sateen" ])
    (g.enum "loom" [ "twill" ])
    (t.enum [ "satin" ])
  ];
  twin = [
    (t.enum [ "sateen" ])
    (t.enum [ "twill" ])
    (t.enum [ "satin" ])
  ];
  orders = l: [
    l
    [
      (builtins.elemAt l 0)
      (builtins.elemAt l 2)
      (builtins.elemAt l 1)
    ]
    [
      (builtins.elemAt l 1)
      (builtins.elemAt l 0)
      (builtins.elemAt l 2)
    ]
    [
      (builtins.elemAt l 1)
      (builtins.elemAt l 2)
      (builtins.elemAt l 0)
    ]
    [
      (builtins.elemAt l 2)
      (builtins.elemAt l 0)
      (builtins.elemAt l 1)
    ]
    [
      (builtins.elemAt l 2)
      (builtins.elemAt l 1)
      (builtins.elemAt l 0)
    ]
  ];
  at =
    eng: set: v:
    map (o: read eng o v) (orders set);
  every =
    f:
    lib.all f [
      "gen"
      "ref"
    ];
  members = [
    "sateen"
    "twill"
    "satin"
  ];
in
{
  construct = [ "enum-redeclared-across-names-is-nixpkgs-union" ];
  check = asserts (
    every (eng: lib.all (v: at eng mixed v == at "ref" twin v) members)
    # the twin serves every member in every order, so the equality above is not two refusals
    && lib.all (v: !(builtins.elem null (at "ref" twin v))) members
    && every (eng: at eng mixed "bobbin" == builtins.genList (_: null) 6)
  );
}
