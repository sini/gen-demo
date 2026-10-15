# `a-disabled-module-is-removed-with-its-imports` — den-hoag-7o7i9. A module may name others in
# `disabledModules`, and the collection drops each named module with its imports, as nixpkgs'
# `collectModules` does: a path module named by its path takes the module it imports with it, and a keyed
# module is named by its `key`. Both engines read `[ "kept" ]`. The discriminator is the same modules
# without the list, read in the same cell: both engines serve every value, so a collection that ignored
# the list would read four values. gen-merge refused the key by presence before.
{
  asserts,
  genMerge,
  lib,
}:
let
  removed = ../fixtures/disabled-module/removed.nix;
  keyed = {
    key = "weft";
    warp = [ "keyed" ];
  };
  kept.warp = [ "kept" ];
  decl = L: {
    options.warp = L.mkOption {
      type = L.types.listOf L.types.str;
      default = [ ];
    };
  };
  native = mods: (genMerge.evalModuleTree { } ([ (decl genMerge) ] ++ mods)).config.warp;
  nixpkgs = mods: (lib.evalModules { modules = [ (decl lib) ] ++ mods; }).config.warp;
  modules = [
    removed
    keyed
    kept
  ];
  removal = modules ++ [
    {
      disabledModules = [
        removed
        { key = "weft"; }
      ];
    }
  ];
in
{
  construct = [ "a-disabled-module-is-removed-with-its-imports" ];
  check = asserts (
    native removal == [ "kept" ]
    && nixpkgs removal == [ "kept" ]
    && native modules == nixpkgs modules
    && builtins.length (native modules) == 4
  );
}
