# `nulled-module-set-copy` — den-hoag-y4w78. A `//` copy stating `getSubModules = null` contributes no module set:
# nixpkgs reads a declaration's module set off its `getSubModules` alone. Declared twice, the option's submodule
# declares nothing, and `lib.evalModules` refuses the definition; declared once, or beside its plain twin, it is served.
# The copy is of a gen-merge `submodule` at the option's root, inside a gen `attrsOf`, of a gen `nullOr` over it, and
# through the published `defineType`. Before, gen-merge read the `substructure` the copy carried from its base and
# served the twice-declared copy with its base's module set.
{
  asserts,
  genMerge,
  lib,
}:
let
  sub =
    types: mk:
    types.submodule {
      options.a = mk {
        type = types.int;
        default = 0;
      };
    };
  nulled = t: t // { getSubModules = null; };
  # each shape, as a function of a vocabulary (gen-merge's or nixpkgs'), its option builder, a door and the copy
  shapes = {
    root =
      types: mk: _door: c:
      c (sub types mk);
    element =
      types: mk: _door: c:
      types.attrsOf (c (sub types mk));
    container =
      types: mk: _door: c:
      types.attrsOf (c (types.nullOr (sub types mk)));
    door =
      types: mk: door: c:
      types.attrsOf (door (c (sub types mk)));
  };
  value = {
    root.a = 1;
    element.k.a = 1;
    container.k.a = 1;
    door.k.a = 1;
  };
  read =
    eval: types: mk: door: shape: copies:
    let
      r = builtins.tryEval (
        let
          x =
            (eval (
              map (c: { options.x = mk { type = shapes.${shape} types mk door c; }; }) copies
              ++ [ { x = value.${shape}; } ]
            )).config.x;
        in
        builtins.deepSeq x x
      );
    in
    if r.success then r.value else null;
  gen = read (genMerge.evalModuleTree { }) genMerge.types genMerge.mkOption genMerge.types.defineType;
  ref = read (modules: lib.evalModules { inherit modules; }) lib.types lib.mkOption (t: t);
  arrangements = {
    twice = [
      nulled
      nulled
    ];
    once = [ nulled ];
    copyFirst = [
      nulled
      (t: t)
    ];
    plainFirst = [
      (t: t)
      nulled
    ];
  };
  refused = arrangement: arrangement == "twice";
in
{
  construct = [ "a-nulled-module-set-copy-contributes-no-modules" ];
  check = asserts (
    lib.all (
      shape:
      lib.all (
        a:
        let
          g = gen shape arrangements.${a};
          n = ref shape arrangements.${a};
        in
        g == n && (n == null) == refused a
      ) (builtins.attrNames arrangements)
    ) (builtins.attrNames shapes)
  );
}
