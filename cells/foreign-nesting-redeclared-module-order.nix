# `foreign-nesting-redeclared-module-order` — C173, den-hoag-z75vj. One option is declared three
# times, by a nixpkgs nesting type and two gen-merge ones, in every order, each nested module
# defining the same list; once as `submodule`s and once as module trees (a tree and a `submodule`
# do not join: their shorthand settings conflict, as in C167). The nested module set of the
# redeclared option is the authored concatenation of the declarations' own sets, as nixpkgs'
# `fixupOptionType` rebuilds it, so the merged list reads in the order `lib.evalModules` reads it.
# Before, the join's own module list survived whenever a foreign type was in the fold, and every
# order read differently.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  npModule = {
    options.l = lib.mkOption { type = t.listOf t.str; };
    config.l = [ "np" ];
  };
  genModule = tag: { config.l = [ tag ]; };
  tree = modules: (genMerge.evalModuleTree { inherit modules; }).type;
  families = {
    submodule = {
      np = t.submodule [ npModule ];
      gen = genMerge.types.submodule [ (genModule "gen") ];
      other = genMerge.types.submodule [ (genModule "other") ];
    };
    tree = {
      np = (lib.evalModules { modules = [ npModule ]; }).type;
      gen = tree [ (genModule "gen") ];
      other = tree [ (genModule "other") ];
    };
  };
  orders = [
    [
      "np"
      "gen"
      "other"
    ]
    [
      "np"
      "other"
      "gen"
    ]
    [
      "gen"
      "np"
      "other"
    ]
    [
      "gen"
      "other"
      "np"
    ]
    [
      "other"
      "np"
      "gen"
    ]
    [
      "other"
      "gen"
      "np"
    ]
  ];
  read =
    eval: kinds: order:
    let
      r = builtins.tryEval (
        let
          l =
            (eval {
              modules = map (k: { options.x = lib.mkOption { type = kinds.${k}; }; }) order ++ [ { x = { }; } ];
            }).config.x.l;
        in
        builtins.deepSeq l l
      );
    in
    if r.success then r.value else null;
  gen = read genMerge.evalModuleTree;
  ref = read lib.evalModules;
in
{
  construct = [ "C173" ];
  check = asserts (
    lib.all (
      f:
      lib.all (o: ref f o != null && gen f o == ref f o) orders
      &&
        ref f [
          "np"
          "gen"
          "other"
        ] == [
          "other"
          "gen"
          "np"
        ]
    ) (builtins.attrValues families)
  );
}
