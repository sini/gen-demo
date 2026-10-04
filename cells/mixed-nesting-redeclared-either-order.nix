# `mixed-nesting-redeclared-either-order` — C167, den-hoag-mixed-nesting-redecl-order-4v489. One
# option is declared by a nixpkgs `submodule` in one module and a gen-merge `submodule` in the
# other. nixpkgs serves the pair in both orders; gen-merge refused it in both orders under its own
# engine, and in nixpkgs' engine whenever nixpkgs' declaration came first, because gen's nesting
# relation could not read the partner's `submoduleWith` payload. gen's relation now hands the pair
# to the partner's own functor relation, so the option resolves to nixpkgs' value in both orders on
# both engines, equal to the nixpkgs × nixpkgs twin. The control: a shorthand conflict
# (`submoduleWith { shorthandOnlyDefinesConfig = false; }` beside gen's `submodule`) still refuses
# in both orders on both engines, as nixpkgs refuses its twin.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  served =
    eval: mods:
    let
      r = builtins.tryEval (
        let
          v = (eval mods).config.loom;
        in
        builtins.deepSeq v v
      );
    in
    if r.success then r.value else null;
  engines = {
    gen = served (modules: genMerge.evalModuleTree { } modules);
    ref = served (modules: lib.evalModules { inherit modules; });
  };
  warp = {
    options.warp = lib.mkOption {
      type = t.int;
      default = 2;
    };
  };
  declare = type: { options.loom = lib.mkOption { inherit type; }; };
  defined = {
    loom.weft = 3;
  };
  weftOption.options.weft = lib.mkOption { type = t.int; };
  np = t.submodule [ warp ];
  gm = genMerge.types.submodule [ weftOption ];
  twin = t.submodule [ weftOption ];
  conflicting = t.submoduleWith {
    modules = [ warp ];
    shorthandOnlyDefinesConfig = false;
  };
  orders = a: b: [
    [
      (declare a)
      (declare b)
      defined
    ]
    [
      (declare b)
      (declare a)
      defined
    ]
  ];
  every =
    f:
    lib.all (eng: lib.all f (map engines.${eng} (orders np gm))) [
      "gen"
      "ref"
    ];
in
{
  construct = [ "C167" ];
  check = asserts (
    lib.all
      (
        eng:
        map engines.${eng} (orders np gm) == map engines.${eng} (orders np twin)
        &&
          map engines.${eng} (orders conflicting gm) == [
            null
            null
          ]
        &&
          map engines.${eng} (orders conflicting twin) == [
            null
            null
          ]
      )
      [
        "gen"
        "ref"
      ]
    && every (
      v:
      v == {
        warp = 2;
        weft = 3;
      }
    )
  );
}
