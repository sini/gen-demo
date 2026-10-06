# `functor-name-redeclared-either-order` — C194, den-hoag-caxcw + den-hoag-khltw. One option is
# declared by a nixpkgs container and by the gen-merge constructor of the same construction, which
# nixpkgs states under ANOTHER functor name: `attrsOf` is nixpkgs' `attrsWith`, `deferredModule` its
# `deferredModuleWith`. nixpkgs keys a redeclaration on the functor name, so the pair refused in both
# orders on both engines (attrs), or served in one order only, dropping the nixpkgs side's static
# modules (deferred). gen-merge now publishes each under the richer name and joins a partner stated
# under it in the partner's own relation, so the option has its nixpkgs × nixpkgs twin's answer in
# both orders on both engines, and a static module survives. The control: nixpkgs' `lazyAttrsOf`
# beside gen's `attrsOf` still refuses in both orders on both engines, as nixpkgs refuses its twin.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  g = genMerge.types;
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
    gen = served (genMerge.evalModuleTree { });
    ref = served (modules: lib.evalModules { inherit modules; });
  };
  declare = type: { options.loom = lib.mkOption { inherit type; }; };
  # a deferred module's value is read by evaluating its imports beside the options it sets
  heddle = {
    options.warp = lib.mkOption {
      type = t.int;
      default = 0;
    };
    options.weft = lib.mkOption {
      type = t.int;
      default = 0;
    };
  };
  woven =
    v:
    if v == null then
      null
    else
      { inherit ((lib.evalModules { modules = [ heddle ] ++ v.imports; }).config) warp weft; };
  orders = a: b: def: [
    [
      (declare a)
      (declare b)
      { loom = def; }
    ]
    [
      (declare b)
      (declare a)
      { loom = def; }
    ]
  ];
  pairs = {
    attrs = {
      np = t.attrsOf t.int;
      gm = g.attrsOf g.int;
      twin = t.attrsOf t.int;
      def.shuttle = 1;
      read = v: v;
    };
    static = {
      np = t.deferredModuleWith { staticModules = [ { weft = 7; } ]; };
      gm = g.deferredModule;
      twin = t.deferredModule;
      def.warp = 5;
      read = woven;
    };
  };
  sameAsTwin =
    eng: p:
    map (m: p.read (engines.${eng} m)) (orders p.np p.gm p.def)
    == map (m: p.read (engines.${eng} m)) (orders p.np p.twin p.def);
  every =
    f:
    lib.all f [
      "gen"
      "ref"
    ];
in
{
  construct = [
    "nixpkgs-container-and-its-gen-twin-under-another-functor-name-serve-in-either-order"
  ];
  check = asserts (
    every (eng: sameAsTwin eng pairs.attrs && sameAsTwin eng pairs.static)
    &&
      map (m: pairs.static.read (engines.ref m)) (orders pairs.static.np pairs.static.gm pairs.static.def)
      == [
        {
          warp = 5;
          weft = 7;
        }
        {
          warp = 5;
          weft = 7;
        }
      ]
    &&
      map engines.gen (orders pairs.attrs.np pairs.attrs.gm pairs.attrs.def) == [
        { shuttle = 1; }
        { shuttle = 1; }
      ]
    && every (
      eng:
      map engines.${eng} (orders (t.lazyAttrsOf t.int) (g.attrsOf g.int) { shuttle = 1; }) == [
        null
        null
      ]
    )
  );
}
