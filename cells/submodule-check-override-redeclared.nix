# `submodule-check-override-redeclared` — den-hoag-59gnz (owner-ruled 2026-10-08, arm (b)). A gen
# `submodule` whose check is overridden, by nixpkgs `addCheck` (over a module set, nixpkgs' `addCheck`
# is the ad-hoc `// { check }` override) and by the override written out, is redeclared beside the
# plain submodule in either order, raw and re-completed through `types.defineType` and `mkOptionType`.
# The override is enforced: `{ a = 2; }`, which it admits, is served, and `{ a = 1; }`, which it
# rejects, is refused by name. The redeclaration used to be refused whole, raw, and the re-completed
# override's check dropped, serving `{ a = 1; }`.
{
  asserts,
  genMerge,
  lib,
}:
let
  read =
    types: v:
    (genMerge.evalModuleTree { } (
      map (type: { options.bobbin = genMerge.mkOption { inherit type; }; }) types
      ++ [
        { bobbin = v; }
      ]
    )).config.bobbin;
  refused = v: !(builtins.tryEval (builtins.deepSeq v null)).success;
  plain = genMerge.types.submodule { options.a = genMerge.mkOption { type = genMerge.types.int; }; };
  notOne = v: v.a != 1;
  overrides = [
    (lib.types.addCheck plain notOne)
    (plain // { check = v: plain.check v && notOne v; })
  ];
  doors = [
    (d: d)
    genMerge.types.defineType
    genMerge.mkOptionType
  ];
  enforced =
    d:
    lib.all (types: read types { a = 2; } == { a = 2; } && refused (read types { a = 1; })) [
      [
        plain
        d
      ]
      [
        d
        plain
      ]
    ];
in
{
  construct = [ "a-submodule-check-override-is-enforced-beside-its-twin" ];
  check = asserts (lib.all (door: lib.all (o: enforced (door o)) overrides) doors);
}
